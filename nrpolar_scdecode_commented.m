% Reliability sequence
% This is a pre-computed sequence that orders the bit-channels from least reliable to most reliable.
% The +1 at the end adjusts it from 0-based indexing to MATLAB's 1-based indexing.
Q=[0 1 2 4 8 16 32 3 5 64 9 6 17 10 18 128 12 33 65 20 256 34 24 36 7 129 66 512 11 40 68 130 ...
    ... (long list of numbers) ...
    1022 1023]+1;

% --- System Parameters ---
N = 1024;       % Codeword length (total bits per block)
K = 512;        % Message length (information bits per block)
n = log2(N);    % Number of polar transform stages

% --- Channel Parameters ---
EbNodB = 4;     % Eb/No in decibels (Signal-to-Noise Ratio per bit)
Rate = K/N;     % Code rate
EbNo = 10^(EbNodB/10); % Convert Eb/No from dB to linear scale
sigma = sqrt(1/(2*Rate*EbNo)); % Calculate noise standard deviation for AWGN channel

% --- Bit-Channel Selection ---
% Select the portion of the reliability sequence relevant for the code length N
Q1 = Q(Q<=N); 

% The first N-K indices from the reliability sequence are the least reliable channels.
% These will be the "frozen" bit positions.
F = Q1(1:N-K); % Frozen positions

% The last K indices from the reliability sequence are the most reliable channels.
% These will be the "message" bit positions.
% Message positions are implicitly defined as Q1(N-K+1:end)

% --- Simulation Setup ---
Nbiterrs = 0;   % Counter for bit errors
Nblkerrs = 0;   % Counter for block errors (frames with at least one error)
Nblocks = 100;  % Total number of blocks to simulate

% --- Main Simulation Loop ---
for blk = 1:Nblocks
    % 1. Message Generation
    msg = randi([0 1],1,K); % Generate a random K-bit message
    
    % 2. Polar Encoding
    u = zeros(1,N);         % Initialize the pre-encoded vector with all zeros (for frozen bits)
    u(Q1(N-K+1:end)) = msg; % Place the message bits into the most reliable positions
    
    % Apply the polar transform recursively to get the codeword
    m = 1; % Start with combining single bits
    for d = n-1:-1:0 % Iterate through the n stages of encoding
        for i = 1:2*m:N % Apply the core transform to pairs of blocks
            a = u(i:i+m-1);      % Get the first part
            b = u(i+m:i+2*m-1);  % Get the second part
            u(i:i+2*m-1) = [mod(a+b,2) b]; % The core polar transform: [u1+u2, u2]
        end
        m = m * 2; % Double the block size for the next stage
    end
    cword = u; % The final encoded vector is the codeword
    
    % 3. Modulation and Channel
    s = 1 - 2 * cword;          % BPSK modulation: 0 -> +1, 1 -> -1
    r = s + sigma * randn(1,N); % Additive White Gaussian Noise (AWGN) channel
    
    % 4. Successive Cancellation (SC) Decoder
    L = zeros(n+1,N);     % Matrix to store Log-Likelihood Ratios (LLRs) or "beliefs"
    ucap = zeros(n+1,N);  % Matrix to store hard decisions (u_hat)
    ns = zeros(1,2*N-1);  % Node state vector to track the decoder's path in the tree
    
    % Core LLR update functions for the SC decoder
    f = @(a,b) (1-2*(a<0)).*(1-2*(b<0)).*min(abs(a),abs(b)); % Check node update (min-sum approximation)
    g = @(a,b,c) b+(1-2*c).*a; % Variable node update
    
    L(1,:) = r; % Initialize beliefs at the root of the tree with the received signal
    
    node = 0; depth = 0; % Start traversal at the root node (node 0, depth 0)
    done = 0;            % Flag to indicate when decoding is finished
    
    while (done == 0) % Traverse the code tree until all bits are decoded
        % Check if we are at a leaf node
        if depth == n
            if any(F==(node+1)) % Check if the current bit position is frozen
                ucap(n+1,node+1) = 0; % Frozen bits are decoded as 0
            else
                % For message bits, make a hard decision based on the LLR sign
                if L(n+1,node+1) >= 0
                    ucap(n+1,node+1) = 0; % Positive LLR -> bit is 0
                else
                    ucap(n+1,node+1) = 1; % Negative LLR -> bit is 1
                end
            end
            
            if node == (N-1)
                done = 1; % If this was the last bit, we are done
            else
                % Move up to the parent node
                node = floor(node/2); depth = depth - 1;
            end
        else
            % We are at an internal (non-leaf) node
            npos = (2^depth-1) + node + 1; % Position in the node state vector
            
            if ns(npos) == 0 % State 0: First visit. Go to the left child (Step L).
                temp = 2^(n-depth);
                Ln = L(depth+1,temp*node+1:temp*(node+1)); % Incoming beliefs
                a = Ln(1:temp/2); b = Ln(temp/2+1:end); % Split beliefs
                
                node = node * 2; depth = depth + 1; % Move to left child
                
                temp = temp / 2;
                % Calculate LLRs for the left child using the 'f' function and store them
                L(depth+1,temp*node+1:temp*(node+1)) = f(a,b); 
                ns(npos) = 1; % Update state to 1 (visited left child)
                
            elseif ns(npos) == 1 % State 1: Visited left child. Go to the right child (Step R).
                temp = 2^(n-depth);
                Ln = L(depth+1,temp*node+1:temp*(node+1)); % Incoming beliefs
                a = Ln(1:temp/2); b = Ln(temp/2+1:end); % Split beliefs
                
                lnode = 2*node; ldepth = depth + 1;
                ltemp = temp/2;
                % Get the decisions from the already-decoded left child
                ucapn = ucap(ldepth+1,ltemp*lnode+1:ltemp*(lnode+1)); 
                
                node = node * 2 + 1; depth = depth + 1; % Move to right child
                
                temp = temp / 2;
                % Calculate LLRs for the right child using the 'g' function and store them
                L(depth+1,temp*node+1:temp*(node+1)) = g(a,b,ucapn);
                ns(npos) = 2; % Update state to 2 (visited both children)
                
            else % State 2: Visited both children. Go up to the parent (Step U).
                temp = 2^(n-depth);
                lnode = 2*node; rnode = 2*node + 1; cdepth = depth + 1;
                ctemp = temp/2;
                
                % Get decisions from left and right children
                ucapl = ucap(cdepth+1,ctemp*lnode+1:ctemp*(lnode+1)); 
                ucapr = ucap(cdepth+1,ctemp*rnode+1:ctemp*(rnode+1)); 
                
                % Combine decisions from children to form the decision for the parent node
                ucap(depth+1,temp*node+1:temp*(node+1)) = [mod(ucapl+ucapr,2) ucapr];
                
                % Move up to the parent node
                node = floor(node/2); depth = depth - 1;
            end
        end
    end
    
    % 5. Error Counting
    % Extract the decoded message from the final decision vector at the message positions
    msg_cap = ucap(n+1,Q1(N-K+1:end));
    
    % Count the number of errors in the current block
    Nerrs = sum(msg ~= msg_cap);
    if Nerrs > 0
        Nbiterrs = Nbiterrs + Nerrs; % Add to total bit error count
        Nblkerrs = Nblkerrs + 1;     % Increment block error count
    end
end

% --- Calculate Final Results ---
BER_sim = Nbiterrs/K/Nblocks; % Calculate Bit Error Rate
FER_sim = Nblkerrs/Nblocks;   % Calculate Frame (Block) Error Rate

% Display the simulation results
disp([EbNodB FER_sim BER_sim Nblkerrs Nbiterrs Nblocks])