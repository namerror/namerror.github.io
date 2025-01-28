---
title: "String Manipulation in Python"
date: 2025-01-28
categories: tech programming python
---
This post is a very easy warm-up. I included some tricks for string manipulation in Python. Popular methods like replace() are **not** included here because they are too popular!

## Checking String Type
# Using isX methods
Let's get straight to the point:

{% highlight python %}
"Hello".isalpha() # Returns whether all characters in the string are alphabetic
"1234xyz".isalnum() # Returns whether all characters in the string are alphanumeric
"1234".isdecimal() # Returns whether all characters in the string are decimals
" \n".isspace() # Returns whether all characters in the string are whitespaces
"Hello".istitle() # Returns whether the string follows the rules of a title

# all the above lines should return True
{% endhighlight %}
There are more isX methods. This type of method is extremely useful for validating user inputs etc.

# Checking start and end
We use startswith() and endswith() to check the \___ and \___ of a string. *If you can't fill the blanks maybe you should reconsider your decision to learn coding.*
{% highlight python %}
"Hello world!".startswith("Hello") # Returns whether the string starts with the specified value
"Hello world!".endswith("world!") # Returns whether the string ends with the specified value

# Returns:
# True
# True
{% endhighlight %}

## String Manipulation
# Join and split
Although these are also very common methods, I'm still giving them an honorable mention.
{% highlight python %}
print(', '.join(['a', 'b', 'c'])) # 'a, b, c'
print('abc'.split('b')) # ['a', 'c']
# split() by default splits by whitespaces
print('My name is Leon'.split()) # ['My', 'name', 'is', 'Leon']
{% endhighlight %}
join() adds a string to in between the elements of a list to make a new string, split() does the exact opposite by breaking down a string to a list.
# Strip
By using strip(), lstrip(), and rstrip() we can remove certain parts of a string.
{% highlight python %}
" Hello ".lstrip() # removes leading whitespaces -> "Hello "
"SSSHelloSSS".lstrip("S") # removes leading 'S' -> "HelloSSS"
"-Hello-".rstrip("-") # '-Hello'
"SPAMHelloSPAMSPAM".strip("SPAM") # 'Hello'
{% endhighlight %}
# Justifying strings
We can justify strings using ljust() to the left, rjust() to the right, center() to center
{% highlight python %}
print("Hello".ljust(10)) # justify the string to the left within 10 spaces (padding with 5 spaces to the right)
print("Hello".rjust(10)) # justify the string to the right within 10 spaces (padding with 5 spaces to the left)
print("Hello".ljust(10, '*')) # justify the string to the left within 10 spaces (padding with 5 '*' to the right)
print("Hello".center(11, '-')) # justify the string to the center within 11 spaces (padding with 3 '-' to the left and right)
'''
Output:
Hello     
     Hello
Hello*****
---Hello---
'''
{% endhighlight %}
## Using Pyperclip to Copy/Paste
To use pyperclip, first install the library by running `pip install pyperclip`. (**NOT paperclip!**)

In the script, always remember to import pyperclip
{% highlight python %}
import pyperclip
pyperclip.copy('Hello world!') # copy the string
# if copied elsewhere after the line above, the output would be different
print(pyperclip.paste()) # 'Hello world!'
{% endhighlight %}
---

That's all. The code might look a bit messy because I was hesitating for every example whether I should include the print() function or not, only for the sake of showcasing the usage of the methods, I apologize for the confusion it might have caused.
> You must continue the journey without me. - Master Oogway