from pdfminer.high_level import extract_text
import re

lab_file = 'pdf/Labour-Party-manifesto-2024.pdf'
text = extract_text(lab_file)

## Remove header lines
### These have 'Change  Labour Party Manifesto 2024'
pattern = r"Change\s+Labour Party Manifesto 2024"
cleaned_text = re.sub(pattern, '', text)

### Remove line feeds
cleaned_text = cleaned_text.replace('\x0C', '')

# Replace the bell character with a space
cleaned_text = cleaned_text.replace('\x07', ' ')

### Remove lines which consist solely of a number
# Define a regular expression pattern to match lines that consist only of a number
pattern = r'^\d+$'

# Split the text into lines
lines = cleaned_text.splitlines()
# Filter out lines that match the pattern
filtered_lines = [line for line in lines if not re.match(pattern, line.strip())]
# Join the filtered lines back into a single string
cleaned_text = '\n'.join(filtered_lines)

with open('cleaned/lab.txt', 'w') as file:
    file.write(cleaned_text)

