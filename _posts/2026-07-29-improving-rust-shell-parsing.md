---
layout: blog_post
title: "Improving Rust Shell Parsing"
categories: rust programming systems string-manipulation
date: 2026-07-29
---

So here I am, back with a better parsing logic for my Rust shell and a couple new features. My previous parsing logic was spaghetti. In case you haven't seen, here's what it roughly looked like:
```rust
fn parse_args(command: &str) -> Vec<String> {
    let mut args: Vec<String> = Vec::new();

    let mut in_single_quote = false;
    let mut string_buf: String= "".to_owned(); // used to construct current arg
    let mut quote: String = "".to_owned();
    let mut is_prev_quote = false;


    for c in command.chars() {
        if in_single_quote {
            if c == '\'' {
                in_single_quote = false;
                is_prev_quote = true
            } else {
                quote.push(c);
            }
        } else {
            if c == '\'' {
                in_single_quote = true
            } else if is_prev_quote {
                if &quote != "" {
                    string_buf.push_str(&quote);
                    let arg = string_buf.clone();
                    args.push(arg);
                    string_buf = "".to_owned();                
                } 
                is_prev_quote = false;
                quote = "".to_owned();
                if c == ' ' {
                    continue;
                }
                string_buf.push(c);
            } else if c == ' '{
                if !string_buf.is_empty() {
                    args.push(string_buf.clone());
                    string_buf = "".to_owned();
                }               
            } else {
                string_buf.push(c);
            }
        }
    }
    string_buf.push_str(&quote);
    args.push(string_buf.clone());

    return args
}
```

I figured out a cleaner approach, and I've added support for double quotes, escape characters and their interaction with one another. Here's the new parsing logic:

```rust
fn parse_args(command: &str) -> Vec<String> {
    let mut args: Vec<String> = Vec::new();

    let mut in_single_quote = false;
    let mut in_double_quote = false;
    let mut string_buf: String= "".to_owned(); // used to construct current arg
    let mut escaped = false; // if the current character should be escaped

    for c in command.chars() {
        if escaped {
            string_buf.push(c);
            escaped = false;
            continue;
        }
        match c {
            '\'' => {
                if !in_double_quote {
                    in_single_quote = !in_single_quote;
                } else {
                    string_buf.push(c);
                }
            }
            '\\' => {
                if !in_single_quote {
                    escaped = true;
                } else {
                    string_buf.push(c);
                }
            }
            '"' => {
                if !in_single_quote {
                    in_double_quote = !in_double_quote;
                } else {
                    string_buf.push(c);
                }
            }
            ' ' => {
                if in_single_quote || in_double_quote {
                    string_buf.push(c);
                } else if !string_buf.is_empty() {
                    args.push(string_buf.clone());
                    string_buf.clear();
                }
            }
            _ => string_buf.push(c),
        }
    }

    if !string_buf.is_empty() {
        args.push(string_buf.clone());
    }

    return args
}
```

This is a lot better.

Next I'll be working on redirection, completions, background jobs, pipelines, history, parameter expansion etc. Hopefully I can get the whole project done in the next two days. Depending on the time I have, I might just give up on the minor features like completions and history. I want to get the core features done first.