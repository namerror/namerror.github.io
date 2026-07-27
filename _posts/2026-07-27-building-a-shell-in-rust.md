---
layout: blog_post
title: "Building a Shell in Rust"
categories: rust programming systems
date: 2026-07-27
---

Agentic coding has corrupted my mind, I've been wanting to take a break from the sort of fast-paced development and restore the feeling of writing code line by line. So recently I've been experimenting with Rust, and I stumbled upon this challenge of building my own shell, and I thought, why not? I've always liked low-level stuff.

Rust is a sociapathic language, but I see how it's a good language for systems programming, and I think it will become a good language in the AI-coding era - it throws the AI-created slop to compilers and forces the LLM to write safer code. But I dug a hole for myself and now I'm stuck with Rust, so let's see how far I can go with this shell project.

Throughout this project, I tried to write everything by myself, no AI, not following any example code. I used codecrafters.io as a guide to the project and a testing platform, it gives you a good step-by-step project development system. The platform's code examples use libraries to simplify a lot of things, so I didn't follow them at all(you can tell by how ugly my implementation is).

Link to my project is [here](https://github.com/namerror/shell-rust).

As of today, I've completed the following features:

### Base 
- Implement REPL, `exit`, handle invalid commands
- `echo` command
- `type` command
- Support for locating/calling executables in PATH

### Navigation
- `cd` command
- `pwd` command

### Quoting
- Support single quote parsing

Currently I'm still in quoting, but it's slowly becoming a nightmare. It's not systems programming anymore, a lot of the shell work is just parsing and string manipulation. I think if it continues like this, I might just start using libraries to help with parsing. Here's an example of how I parse arguments without libraries:

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

This is just one snippet of initial parsing, and it doesn't even handle double quotes yet. I think I might just use a library to help with this, because this is just too much work for a shell.

---
Below is the full code of the shell as of today. At least it works.

```rust
use std::fs::metadata;
use std::io::Error;
#[allow(unused_imports)]
use std::io::{self, Write};
use std::os::unix::fs::PermissionsExt;
use std::path::PathBuf;
use std::{print, string};
use std::{env, fs};
use std::process::Command;

fn main() {
    let path = env::var("PATH").unwrap();
    let paths: Vec<&str> = path.split(":").collect();
    let mut dir = env::current_dir().unwrap();
    loop {
        print!("$ ");
        io::stdout().flush().unwrap(); // uses flush to ensure the prompt is displayed before reading input
        let mut command = String::new();
        io::stdin().read_line(&mut command).unwrap();

        let command = command.trim();
        let builtins = ["exit", "echo", "type", "pwd", "cd"];

        let string_args = parse_args(&command);
        let args = string_args.iter().map(|s| s.as_str()).collect::<Vec<&str>>();

        match args[0] {
            "" => continue,
            "exit" => break,
            "echo" => handle_echo(&args),
            "type" => handle_type(&args, &paths, &builtins),
            "pwd" => println!("{}", dir.clone().into_os_string().into_string().unwrap()),
            "cd" => match cd(&args, &mut dir) {
                Ok(()) => (),
                Err(_e) => println!("cd: {}: No such file or directory", &args[1])
            },
            _ => {
                if find_executable(&paths, &args[0]).is_ok() {
                    Command::new(&args[0]).args(&args[1..]).status().unwrap();
                } else {
                    println!("{}: command not found", command);
                }
            }
        }
    }
}

fn handle_type(args: &Vec<&str>, paths: &Vec<&str>, builtins: &[&str]) {
    if args.len() != 2 {
        println!("type: wrong args count.");
        return;
    }

    let command = args[1];

    if builtins.contains(&command) {
        println!("{} is a shell builtin", command);
    } else {
        match find_executable(paths, command) {
            Ok(v) => println!("{} is {}", command, v),
            Err(_error) => println!("{}: not found", command),
        };
    }
}

fn find_executable(paths: &Vec<&str>, command: &str) -> Result<String, Error> {
    for path in paths {
        for entry in fs::read_dir(path)? {
            let path = entry?.path();
            if path.is_file() && path.file_name().is_some_and(|x| x==command) {
                let metadata = metadata(&path)?;
                if (metadata.permissions().mode() & 0o111) != 0 {
                    return match path.into_os_string().into_string() {
                        Ok(s) => Ok(s),
                        Err(_s) => Err(Error::new(io::ErrorKind::Other, "Failed"))
                    }
                }
            }
        }
    }

    Err(Error::new(io::ErrorKind::Other, "Failed"))
}

fn cd(args: &Vec<&str>, dir: &mut PathBuf) -> Result<(), Error> {
    if args.len() == 1 {
        *dir = env::home_dir().unwrap();
        Ok(())
    } else if args.len() != 2 {
        Err(Error::new(io::ErrorKind::Other, "Wrong args count."))
    } else {
        let abs_path = resolve_path(args[1], dir.to_owned());
        let canonical = fs::canonicalize(abs_path)?;
        if canonical.is_dir() {
            *dir = canonical.clone();
            Ok(())
        } else {
            Err(Error::new(io::ErrorKind::InvalidInput, "Not a dir."))
        }
    }
}

fn resolve_path(rel_path: &str, dir: PathBuf) -> PathBuf {
    if rel_path.starts_with("~") {
        env::home_dir().unwrap().join(rel_path[1..].to_string())
    } else {
        dir.join(rel_path)
    }
} 

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

fn handle_echo(args: &Vec<&str>) {
    // println!("args: {:?}", args);
    if args.len() < 2 {
        println!();
        return;
    }
    let message = args[1..].join(" ");
    println!("{}", message);
}
```



