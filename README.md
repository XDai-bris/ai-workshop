# IEU AI-for-coding workshop: Practical 2 (Validation)

In this session you **direct an AI agent** to analyse simulated data, and you **validate** what it produces.
You will not write code. All data here are **simulated**: no real people and no real GWAS.

## Before the workshop (about 20 minutes, please do this in advance)

### 1. Install Git and Miniforge

| | Windows | macOS |
|---|---|---|
| Git | Install [Git for Windows](https://git-scm.com/download/win) (default options) | Open Terminal and run `git --version`. If asked, install the command-line tools |
| Miniforge (conda) | Download `Miniforge3-Windows-x86_64.exe` from the [Miniforge releases](https://github.com/conda-forge/miniforge/releases/latest) and install it for "Just Me" (no admin rights needed) | In Terminal: `curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"`, then `bash Miniforge3-$(uname)-$(uname -m).sh` and answer **yes** to the prompts. Then close and reopen Terminal |

Already have Anaconda or Miniconda? You can use it instead: the environment below uses only the free conda-forge channel.

### 2. Get this repository

Put it in a folder that is **not** synced by OneDrive and has **no spaces** in its path.

| Windows (open **Miniforge Prompt** from the Start menu) | macOS (Terminal) |
|---|---|
| `mkdir C:\ieu-ai` | `mkdir -p ~/ieu-ai` |
| `cd C:\ieu-ai` | `cd ~/ieu-ai` |
| `git clone https://github.com/XDai-bris/ai-workshop.git` | `git clone https://github.com/XDai-bris/ai-workshop.git` |
| `cd ai-workshop` | `cd ai-workshop` |

### 3. Create the R environment (5–10 minutes, needs internet)

Same command on Windows and macOS, run inside the repository folder:

```
conda env create -f environment.yml
```

### 4. Check it works

```
conda run -n ieu-ai-workshop Rscript setup/check_setup.R
```

You should see **`SETUP OK`** at the end.

### 5. Check your AI agent can run it too

Open this folder in your AI coding tool (for example VS Code with your agent). Ask the agent:

> Read AGENTS.md, then run the setup check described in README.md and tell me the result.

It should report `SETUP OK`. This shows the agent can run R for you.

### If something goes wrong

- **`conda` not found (macOS):** close and reopen Terminal. If it still fails, run `~/miniforge3/bin/conda init zsh` and reopen Terminal.
- **`conda` not found (Windows):** use **Miniforge Prompt**, not plain PowerShell. To use PowerShell, run `conda init powershell` once in Miniforge Prompt, then reopen PowerShell.
- **Installers blocked on a managed laptop:** tell the organisers. You can follow along on the presenter's screen.
- **Still stuck:** send the organisers the full output of the step-4 command.

## What's in this repository

| Path | What it is |
|---|---|
| `PROBLEM_STATEMENT.md` | The research question |
| `data/` | Simulated GWAS summary statistics; start with `data/DATA_DICTIONARY.md` |
| `spec/` | Your analysis specification (`spec_template.md` → `spec.md`) |
| `AGENTS.md` | Rules your AI agent follows in this repository |
| `prompts/` | Prompts used during the session |
| `colleague_pipeline/` | A colleague's AI-built analysis that you will be asked to check |
| `checkpoints/` | Catch-up files if you fall behind |
| `analysis/`, `results/` | Where your agent writes code and outputs |
| `environment.yml`, `setup/` | The R environment and its check |
