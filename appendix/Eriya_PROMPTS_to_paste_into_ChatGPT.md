# Assignment 3 - Prompt Pack for ChatGPT

**Student:** Paula Eriya  **Module:** BDA400 / Data Science Tools and Techniques
**AI tool used:** ChatGPT (free tier, chatgpt.com)
**Tool version / date used:** ______________________  ← *fill this in before you submit*

---

## How to use this file

Work through the prompts **in order**. After each one, ChatGPT gives you an answer.

1. Copy the prompt text from the grey box.
2. Paste it into a **new chat** in ChatGPT (keep one chat per step, or use one chat and scroll back).
3. Copy ChatGPT's **full reply** back into this file, under `PASTE CHATGPT'S REPLY HERE`.
4. Save the file as `Assignment3/appendix/Eriya_ChatGPT_transcript.md`.

Do not skip a step. The brief marks you on *multiple refinements*, so the conversation has to show
progress. The numbering `P1`, `P2` … lets you refer to them in your report.

---

## P1 - Seed prompt (Step 1, required by the brief)

```
Write an R function that removes outliers from a numeric vector using the 1.5 times IQR rule.
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## P2 - Add validation, comments and a clean result (Step 1, refinement 1)

```
Revise the function to include comments, argument validation, and return a clean result.
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## P3 - Line-by-line explanation and how to test it (Step 1, refinement 2)

```
Explain what each line of the R code does and how you might test if it works correctly.
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## P4 - Paste the real error you hit in RStudio (Step 2, bug fix)

> **Do this one only after you have actually run the function in RStudio.**
> Copy the *real* red error message out of the R console into the prompt.

```
I ran your function in RStudio and it gave this error:

<PASTE THE REAL ERROR MESSAGE FROM THE R CONSOLE HERE>

Here is the function I ran:

<PASTE THE FUNCTION HERE>

Please fix the error and explain what caused it.
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## P5 - NA values, edge cases and options (Step 2, refinement 2)

```
Update the function to handle NA values, empty vectors, and vectors with too few
observations. Also let me choose the multiplier (not always 1.5) and let me choose
how the quartiles are calculated, because boxplot.stats() in R uses a different
quartile method to quantile() and I want to be able to compare the two.
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## P6 - Efficiency and readability (Step 2, refinement 3)

```
Optimize the function for efficiency and readability.
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## P7 - How to test it (Step 2, refinement 4)

```
How could you test this function with edge cases?
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## P8 - Summarise the revisions (Step 3, required by the brief)

```
Summarize how this R function changed across revisions. Highlight what improvements
were human-driven vs AI-generated.
```

**PASTE CHATGPT'S REPLY HERE**

```
(ChatGPT's answer goes here)
```

---

## Privacy note (AI Usage Rule 9)

Everything sent to ChatGPT in this assignment is **synthetic data invented for the task** -
for example `c(10, 15, 999, 20, 25)` or a random vector made with `set.seed(42)`. No real,
personal, confidential or college data is sent to any AI tool at any point.
