from pdfminer.high_level import extract_text
import re

plaid_file = 'pdf/Plaid_Cymru_Maniffesto_2024_ENGLISH.pdf'
text = extract_text(plaid_file)

## Remove header lines
### These have 'Plaid UK: Our Contract with You'
pattern = r"Plaid Cymru Manifesto 2024"
cleaned_text = re.sub(pattern, '', text)

pattern = r"partyof.wales"
cleaned_text = re.sub(pattern, '', cleaned_text)

### Remove line feeds
cleaned_text = cleaned_text.replace('\x0C', '')

# Replace the bell character with a space
cleaned_text = cleaned_text.replace('\x07', ' ')

### Remove lines which consist solely of a number
# Define a regular expression pattern to match lines that plaidsist only of a number
pattern = r'^\d+$'

# Split the text into lines
lines = cleaned_text.splitlines()
# Filter out lines that match the pattern
filtered_lines = [line for line in lines if not re.match(pattern, line.strip())]
# Join the filtered lines back into a single string
cleaned_text = '\n'.join(filtered_lines)

### Remove lines which consist solely of a single character in range A-Za-z]
# Define a regular expression pattern to match lines that plaidsist only of a number
pattern = r'^[a-zA-Z]$'

# Split the text into lines
lines = cleaned_text.splitlines()
# Filter out lines that match the pattern
filtered_lines = [line for line in lines if not re.match(pattern, line.strip())]
# Join the filtered lines back into a single string
cleaned_text = '\n'.join(filtered_lines)



# Replace the Unicode character U+2771 with a dash
cleaned_text = cleaned_text.replace('\u2771', ' - ')


with open('cleaned/plaid.txt', 'w') as file:
    file.write(cleaned_text)
