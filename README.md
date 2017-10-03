# School-Code-Compare

Compare files containing source code (or any plain text) on similarity to each other.
This may help you to find files which contain similar code.

The approach is simplistic:
Whitespace and comments are trimmed, then all files are compared using the Levenshtein algorithm.

Future releases may bring more sophisticated techniques.
