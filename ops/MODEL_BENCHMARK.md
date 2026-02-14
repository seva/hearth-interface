# Ops: High-ROI Model Policy (Issue #39)

**Problem:** Gemini 3 Pro (current default) is expensive (~$100/day pace).
**Constraint:** Agent cannot autonomously benchmark alternative models due to whitelist restrictions.

## Market Analysis (Theoretical Data)

| Model | Class | Input Cost ($/1M) | Output Cost ($/1M) | ROI Score |
| :--- | :--- | :--- | :--- | :--- |
| **Gemini 3 Pro** | Frontier | ~$5.00* | ~$15.00* | Low (Burn Hazard) |
| **DeepSeek V3** | SOTA Value | $0.14 | $0.28 | **Ultra High** |
| **Qwen 2.5 72B** | Coding | $0.35 | $0.40 | High |
| **Llama 3 70B** | Standard | $0.23 | $0.40 | Medium |
| **Gemini Flash 2** | Fast | $0.10 | $0.40 | Medium (Low Code IQ) |

*\*Estimates vary by provider.*

## Recommendation: The "DeepSeek Switch"

1.  **Primary Driver:** Switch default agent model to **DeepSeek V3** (`openrouter/deepseek/deepseek-chat`).
    -   *Logic:* It performs at GPT-4o levels for coding/reasoning but costs 95% less.
2.  **Fallback:** Keep Gemini 3 Pro as a fallback for complex/nuanced tasks.
3.  **Config Change:** Requires user to update `openclaw.json` or environment variables to permit this model ID.

## Action Plan
1.  User must add `openrouter/deepseek/deepseek-chat` to agent whitelist.
2.  Once added, I will rotate `defaults.model.primary` to DeepSeek.
