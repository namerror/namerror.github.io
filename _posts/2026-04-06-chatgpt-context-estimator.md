---
layout: blog_post
title: "[Project] ChatGPT Context Estimator"
categories: web javascript extension
date: 2026-04-06
---
## A browser extension that estimates the context usage in the ChatGPT web app.
Recently, I have been working on this chromium-based browser extension that estimates the context usage in the ChatGPT web app. It's pretty simple: it calculates the tokens in the current chat and displays the estimated context usage in the corner of the page. 

### It's Live Now!
Although it's still in beta phase, it's officially live! Check it out: [ChatGPT Context Estimator](https://chromewebstore.google.com/detail/chatgpt-context-counter/opkmjnklfdidolilceocbdhbjhohephg)

The public version v0.9.3 is just a beta version, and there are still many things to improve. 

### Quick Demo
![Demo]({{site.base_url}}/assets/img/contextcounter/demo.png)
![Full Page]({{site.base_url}}/assets/img/contextcounter/fullpage.png)

### Why did I make this?
As a heavy user of ChatGPT, it's easy to lose track of the context usage in long conversations, and we don't like hallucinations. One thing I found really helpful to have is the token usage/context window in Claude Code and Codex, but it seems that the official ChatGPT web app doesn't have this feature. So I decided to make this extension to fill the gap.

### Estimation Method
The extension first parses the conversation contents from the DOM and adds a small fixed token count for each message to simulate how ChatGPT indicates roles in the conversation. Then we apply our estimation methods.
Currently two modes of estimation: fast and precise.
- **Precise** mode uses a tokenizer on the parsed conversation to get the token count, which is more accurate but takes more time (not by much).
- **Fast** mode uses a simple heuristic. We treat every 4 characters as a token, which is a common average token length in English. This method is faster but less accurate, especially for languages with different tokenization patterns.
The user can switch between the two modes in the extension settings.
In the end, we add a system prompt token count (fixed amount) to the total token count to get the final token usage estimation.

### What's the Total Context Window of ChatGPT?
I looked through many official and unofficial sources, and the total context window of ChatGPT is still a mystery. However, based on my research I designed the extension to assign a close estimate of the total context window based on user selected plans (Free, Plus, Enterprise, etc.) and model (as of today the default is 5.3 for Plus users). You can learn more about estimation methods and the context window in the extension's FAQ page (click "learn more" in the extension popup).

### Future Improvements
- Add support for attachments
- Add support for ChatGPT projects
- Better estimation methods (especially for non-English languages)
- More accurate system prompt/tool use token count estimation
- Support for token estimation of different output formats (e.g. markdown, code blocks, etc.)

### Welcoming Feedback and Contributions!
I hope you find this interesting, and please feel free to critique and share your thoughts! The project is open source, and you're welcome to check out the code and contribute! [GitHub Repo](https://github.com/namerror/context-estimator)