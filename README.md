# README

## Table of Contents
- [Project Overview](#project-overview)
- [Objective](#objective)
- [1 · Quick-start (5 commands)](#1--quick-start-5-commands)
- [2 · Project layout](#2--project-layout)
- [3 · Prerequisites](#3--prerequisites)
- [4 · Reproduce the curves step-by-step](#4--reproduce-the-curves-step-by-step)
- [5 · Key technologies](#5--key-technologies)
- [6 · Minimal theory cheat-sheet](#6--minimal-theory-cheat-sheet)
- [Citation](#citation)
- [Contact](#contact)

## Project Overview
Polar codes are a class of error-correcting codes that achieve the channel capacity as block length increases, making them the first known codes to provably reach Shannon’s limit. Introduced by Erdal Arıkan (2008), polar codes leverage a phenomenon called channel polarization to create a set of very reliable channels and very unreliable (frozen) channels from originally identical channels. Because of their capacity-achieving property and efficient decoding, polar codes have been adopted in modern standards like 5G New Radio (for control channel encoding) as a key forward error correction scheme. 
This repository AAC_Polar_Codes contains a Python-based implementation of polar encoding and Successive Cancellation (SC) decoding, along with a simulation framework to evaluate performance. The code encodes messages of length K into codewords of length N (forming a polar code (N, K)), sends them through a simulated noisy channel, and then decodes them using SC. By running Monte Carlo simulations over an AWGN (Additive White Gaussian Noise) channel, the project generates Bit Error Rate (BER) and Frame Error Rate (FER) curves as a function of the signal-to-noise ratio (E<sub>b</sub>/N<sub>0). This allows us to visualize the characteristic “waterfall” performance of polar codes and to analyze how different parameters (like block length N and code rate R = K/N) affect their error-correcting capability.


## Objective
- Implement Polar Coding Theory: Develop a correct polar encoder and SC decoder from scratch in Python, following the theoretical definitions of the polar transform and successive cancellation algorithm.
- Validate Capacity and Polarization Theory: Empirically verify that as block length (N) grows, the polar code under SC decoding approaches capacity (i.e. dramatically lower error rates at moderate SNRs), consistent with Arıkan’s theory of channel polarization.
- BER/FER Performance Evaluation: Simulate the coding scheme over a range of E<sub>b</sub>/N<sub>0> values to measure bit error rate and frame error rate. Compare performance across various block lengths (e.g. 16, 32, 64, …, 512) and code rates (e.g. 0.25, 0.5, 0.75) to observe trends.
- Visualization: Plot the BER/FER vs SNR curves (often on a log-scale for error rates) to illustrate the “waterfall” region where error probabilities drop sharply. These visualizations help in understanding the effect of increasing N or adding redundancy.

This repository accompanies the **Advanced Channel Coding** course project **Simulation and performance analysis of polar codes using a Python implementation** (SS 2025) lectured by **Prof. Dr. Uwe Dettmar** , **Technische Hochschule Koeln**. 

## 1 · Quick-start (5 commands)

*Python (NumPy + Matplotlib) is used for the main simulation loop;  
compact MATLAB .m files show the same encoder / SC-decoder for students who
prefer Octave / MATLAB.*

```bash
git clone https://github.com/sbarai927/AAC_Polar_Codes.git
cd AAC_Polar_Codes
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt         # numpy  matplotlib  jupyter
jupyter notebook Polarcodes_Simulation.ipynb
```

## 2 · Project layout

```bash
AAC_Polar_Codes/
├─ Polarcodes_Simulation.ipynb        # Jupyter demo: end-to-end Python simulation
├─ nrpolar_encode.m                   # 3GPP-style polar encoder (MATLAB/Octave)
├─ nrpolar_scdecode.m                 # Successive-Cancellation decoder (MATLAB)
├─ nrpolar_scdecode_commented.m       # Same decoder, line-by-line commented
├─ results_flat_256_128.csv           # Example raw BER/FER counts (N=256,R=½)
├─ plots/                             # Auto-generated figures ↓
│  ├─ polar_codes_N16_BER_FER.png
│  ├─ polar_codes_N32_BER_FER.png
│  ├─ polar_codes_N64_BER_FER.png
│  ├─ polar_codes_N128_BER_FER.png
│  ├─ polar_codes_N256_BER_FER.png
│  ├─ polar_codes_N512_BER_FER.png
│  └─ polar_codes_N1024_BER_FER.png
└─ README.md                          # you’re reading it 🙂
```
<sub>(tip: regenerate this tree after adding files with
 tree -I '.git|__pycache__|.ipynb_checkpoints|.DS_Store' -L 2 on Linux/macOS)</sub>

 ## 3 · Prerequisites

 | Requirement                              | Min version | Install / hint                                                       | Why it’s needed                                  |
| ---------------------------------------- | ----------- | -------------------------------------------------------------------- | ------------------------------------------------ |
| **Python**                               | 3.9 +       | `sudo apt install python3 python3-venv` <br>or `brew install python` | core simulation (NumPy + Matplotlib)             |
| **pip & venv**                           | latest      | ships with Python · upgrade:<br>`python3 -m pip install -U pip`      | package / virtual-env management                 |
| **NumPy**                                | 1.24        | pulled by `requirements.txt`                                         | vectorised encoder / decoder                     |
| **Matplotlib**                           | 3.7         | pulled by `requirements.txt`                                         | BER / FER plots                                  |
| **Jupyter Lab / Notebook**               | 3 +         | `pip install jupyterlab`                                             | interactive run of `Polarcodes_Simulation.ipynb` |
| **MATLAB (R2022a+)** *or* **GNU Octave** | optional    | Octave: `sudo apt install octave`                                    | run the `.m` reference scripts                   |
| **tree** (CLI utility)                   | any         | `sudo apt install tree` / `brew install tree`                        | regenerate dir-map snippet in README             |

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
jupyter lab          # open notebook UI
```

## 4 · Reproduce the curves step-by-step

| #     | What to do in **Python / Jupyter**                                                                                       | (Optional) MATLAB / Octave path                                                                                                                                                                                                               |
| ----- | ------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1** | **Clone & enter repo**<br>`bash<br>git clone https://github.com/sbarai927/AAC_Polar_Codes.git<br>cd AAC_Polar_Codes<br>` | same `git clone …`                                                                                                                                                                                                                            |
| **2** | **Set-up env**<br>`bash<br>python3 -m venv .venv && source .venv/bin/activate<br>pip install -r requirements.txt<br>`    | just open MATLAB / Octave in this folder                                                                                                                                                                                                      |
| **3** | **Open notebook**<br>`jupyter lab Polarcodes_Simulation.ipynb`                                                           | open `Polarcodes_Simulation.ipynb` via the MATLAB “Notebook” plugin *or* skip to step 3b                                                                                                                                                      |
|  3b   | –                                                                                                                        | **Run driver script**<br>`matlab<br>addpath(pwd);  % make .m files visible<br>N  = 256;           % block length<br>K  = 128;           % information bits<br>EbN0 = 0:0.5:5;     % dB vector<br>[BER,FER] = polar_sim_matlab(N,K,EbN0);<br>` |
| **4** | **Tweak parameters** in the notebook’s second cell:<br>`N`, `K_list`, `EbN0_dBs`, `target_bit_errors`                    | edit the variables above in MATLAB                                                                                                                                                                                                            |
| **5** | **Run → Run All**<br>progress bar prints every 10 frames                                                                 | `polar_sim_matlab` will print a line per SNR point                                                                                                                                                                                            |
| **6** | **Inspect outputs**<br>• PNG curves in `plots/`<br>• raw error counts in `results_flat_*.csv`                            | figures saved to `plots/` by the MATLAB script as well                                                                                                                                                                                        |
| **7** | *(Optional)* regenerate all plots:<br>`python utils/plot_from_csv.py`                                                    | idem, call `plot_from_csv_matlab.m`                                                                                                                                                                                                           |
| **8** | **Clean-up**<br>`deactivate` \&rm; `.venv` if you like                                                                   |                                                                                                                                                                                                                                               |


**Tip for a Faster Turnaround:** Raise target_bit_errors to 25 and shrink EbN0_dBs to 3 points; the waterfall shape is still visible in under a minute.

## 5 · Key technologies

| Layer / topic               | Technology & version hint          | How it’s used in this repo                               |
| --------------------------- | ---------------------------------- | -------------------------------------------------------- |
| **Channel-coding model**    | **Arıkan polar codes** (2009)      | Capacity-approaching (de)coder implemented from scratch  |
| **Decoding algorithm**      | **Successive-Cancellation (SC)**   | `polar_scdecode()` in Python & `nrpolar_scdecode.m`      |
| **Numerical engine**        | **Python + NumPy 1.24 ✚**          | Vectorised bit-operations & LLR math                     |
| **Plotting / figures**      | **Matplotlib 3.7 ✚**               | Log-scale BER/FER “waterfall” curves (saved to `plots/`) |
| **Interactive notebook**    | **Jupyter Notebook / Lab 3 ✚**     | One-click “Run-All” demo                                 |
| **Alt. reference code**     | **MATLAB R2022a / GNU Octave**     | Concise `.m` versions of encoder & decoder               |
| **Progress + CLI niceties** | `tqdm`, `argparse`, `tree` utility | Live progress bars and auto-dir-map in README            |

All required Python packages are pinned in requirements.txt; MATLAB is optional but handy for cross-checking results.

## 6 · Minimal theory cheat-sheet

| Topic                    | Key fact #1                                                              | Key fact #2                                                      |   |    |            |                                                           |
| ------------------------ | ------------------------------------------------------------------------ | ---------------------------------------------------------------- | - | -- | ---------- | --------------------------------------------------------- |
| **Channel polarisation** | Kernel `F = [[1 0],[1 1]]` Kronecker-powered `G = F^{⊗ n}`               | Splits 2ⁿ synthetic channels into “almost-perfect” and “useless” |   |    |            |                                                           |
| **Code construction**    | Pick the *K* best indices from the 5G reliability list (good ⇒ info bit) | Fill the other *N – K* indices with frozen `0`                   |   |    |            |                                                           |
| **Encoder**              | `x = u · G_N   (mod 2)`                                                  | Butterfly XOR network ⇒ **O(N log N)**                           |   |    |            |                                                           |
| **SC decoder**           | \`f(l₁,l₂)=sign(l₁)·sign(l₂)·min(                                        | l₁                                                               | , | l₂ | )\` (left) | `g(l₁,l₂,Û)=(-1)^Û · l₁ + l₂` (right)  → depth-first tree |
| **Complexity**           | Encoder & SC both **O(N log N)**                                         | List-SC ≈ *L*× higher but improves FER                           |   |    |            |                                                           |
| **AWGN link budget**     | BPSK noise σ from `Eb/N0`:<br>`σ = √(1/(2·R·10^(EbN0/10)))`              | Larger *N* → \~0.4 dB SNR gain per doubling (see plots)          |   |    |            |                                                           |


## Citation

1. Arıkan, E. (2009). **Channel polarization: A method for constructing capacity-achieving codes for symmetric binary-input memoryless channels**. *IEEE Transactions on Information Theory*, 55 (7), 3051-3073.  

2. 3GPP. (2024). **TS 38.212: NR; Multiplexing and channel coding (Release 18)**. *3rd Generation Partnership Project Technical Specification*.  

3. Tal, I., & Vardy, A. (2011). **List decoding of polar codes**. *Proceedings of the IEEE International Symposium on Information Theory* (pp. 1-5).  

4. Li, B., Zhang, H., Chen, J., Chen, D., & Lin, K. (2016). **CRC-aided decoding of polar codes**. *IEEE Communications Letters*, 20 (12), 2341-2344.  

5. Sarkis, G., Giard, P., Thibeault, C., & Gross, W. J. (2014). **Fast polar decoders: Algorithm and implementation**. *IEEE Journal on Selected Areas in Communications*, 32 (5), 946-957.  

6. Yuan, J., Huang, A., Lin, J., & Zhang, S. (2018). **Low-complexity SC decoding of polar codes based on bit-reversal permutation**. *IEEE Transactions on Circuits and Systems II*, 65 (5), 640-644.  

7. Mori, R., & Tanaka, T. (2020). **A tutorial on polar codes for 5G cellular systems**. *IEICE Transactions on Communications*, E103-B (4), 339-356.
   

## Contact

For any questions or issues, please contact:
- Manuel Wette, Lisa Schneider, Suvendu Barai
- Email: manuel.wette@smail.th-koeln.de, lisa.schneider@smail.th-koeln.de, suvendu.barai@smail.th-koeln.de


