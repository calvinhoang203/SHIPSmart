from PyPDF2 import PdfReader

# Path to the PDF file
pdf_path = 'UCD-Anthem-Benefit-Book.pdf'
# Path for the output text file
txt_path = 'UCD-Anthem-Benefit-Book.txt'

# Read the PDF and extract text
reader = PdfReader(pdf_path)
all_text = []
for page in reader.pages:
    page_text = page.extract_text()
    if page_text:
        all_text.append(page_text)

# Write the extracted text into the .txt file
with open(txt_path, 'w', encoding='utf-8') as txt_file:
    txt_file.write("\n\n".join(all_text))

print(f"Extraction complete. Text file saved to: {txt_path}")
