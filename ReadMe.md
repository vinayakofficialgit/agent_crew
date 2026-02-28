# Meta Quest Knowledge

A crewAI-powered application that uses an AI agent (Senior DevOps Expert) to answer DevOps questions by retrieving knowledge from PDF documents.

## Prerequisites

- **Python** 3.10 – 3.13
- **uv** — Python package manager ([install guide](https://docs.astral.sh/uv/getting-started/installation/))
- **OpenAI API Key** — required by crewAI for the underlying LLM

## Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd agent_crew
   ```

2. **Install dependencies**

   ```bash
   uv sync
   ```

3. **Set your OpenAI API key**

   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```

   Or create a `.env` file in the project root:

   ```
   OPENAI_API_KEY=your-api-key-here
   ```

> **Tip:** You can also use the provided `setup.sh` script to automate the steps above. See the [Quick Start](#quick-start) section.

## Quick Start

A helper shell script is included to walk you through setup and running the app:

```bash
chmod +x setup.sh
./setup.sh
```

The script will check prerequisites, install dependencies, prompt for your API key, and launch the interactive Q&A session.

## Usage

All commands below should be run from the project root directory.

### Ask a Question (Interactive Mode)

```bash
uv run run_crew
```

You will be prompted to enter a question. The DevOps expert agent will answer using the knowledge sources in the `knowledge/` directory.

### Train the Crew

```bash
uv run train <n_iterations> <output_filename>
```

Example:

```bash
uv run train 5 training_results.json
```

### Test the Crew

```bash
uv run test <n_iterations> <openai_model_name>
```

Example:

```bash
uv run test 3 gpt-4o
```

### Replay a Task

```bash
uv run replay <task_id>
```

## Configuration

| File | Purpose |
|------|---------|
| `src/meta_quest_knowledge/config/agents.yaml` | Defines the AI agent (role, goal, backstory) |
| `src/meta_quest_knowledge/config/tasks.yaml` | Defines tasks the agent can perform |
| `knowledge/devops_notes.pdf` | PDF knowledge source the agent draws answers from |
| `knowledge/user_preference.txt` | User preference metadata |

## Project Structure

```
agent_crew/
├── ReadMe.md
├── setup.sh                          # Setup & run helper script
├── pyproject.toml                    # Project metadata & dependencies
├── uv.lock                          # Dependency lock file
├── knowledge/
│   ├── devops_notes.pdf              # PDF knowledge source
│   └── user_preference.txt           # User preferences
└── src/
    └── meta_quest_knowledge/
        ├── __init__.py
        ├── main.py                   # CLI entry point
        ├── crew.py                   # Crew & agent definitions
        ├── tools/
        │   └── __init__.py
        └── config/
            ├── agents.yaml           # Agent configuration
            └── tasks.yaml            # Task configuration
```

## License

This project is unlicensed. See the repository for details.
