import os
import fitz  # PyMuPDF
from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate
from langchain.schema.output_parser import StrOutputParser

load_dotenv()

# Check for API key
if not os.getenv("GOOGLE_API_KEY"):
    raise ValueError("GOOGLE_API_KEY not found in .env file. Please add it.")

def extract_text_from_pdf(pdf_content: bytes) -> str:
    """Extracts text from a PDF file."""
    text = ""
    with fitz.open(stream=pdf_content, filetype="pdf") as doc:
        for page in doc:
            text += page.get_text()
    return text

import logging

# Set up a logger
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def analyze_energy_fact_sheet(pdf_content: bytes) -> dict:
    """
    Analyzes an energy fact sheet (PDF) to extract key information 
    like fees, penalties, and other charges.
    """
    logger.info("Starting PDF analysis.")
    # 1. Extract text from the PDF
    document_text = extract_text_from_pdf(pdf_content)
    logger.info(f"Extracted {len(document_text)} characters from PDF.")

    # 2. Set up the LLM and Prompt
    llm = ChatGoogleGenerativeAI(model="gemini-1.5-pro-latest", temperature=0)
    
    prompt = ChatPromptTemplate.from_messages(
        [
            ("system", 
             "You are an expert analyst specializing in Australian energy contracts. "
             "Your task is to carefully read the provided energy fact sheet and extract specific financial details. "
             "Focus ONLY on fees, penalties, and charges. Ignore rates, tariffs, and usage costs. "
             "If a fee is not mentioned, state 'Not mentioned'. "
             "Present the output as a structured JSON object."),
            ("human", 
             "Please analyze the following document:\n\n{document}\n\n"
             "Extract the following fees and present them in a JSON format:\n"
             "- Connection Fee\n"
             "- Disconnection Fee\n"
             "- Late Payment Fee\n"
             "- Card Payment Fee\n"
             "- Exit Fee (or Early Termination Fee)\n"
             "- Any other miscellaneous fees mentioned.\n")
        ]
    )

    # 3. Create and run the chain
    chain = prompt | llm | StrOutputParser()
    
    logger.info("Invoking LLM chain.")
    result_str = chain.invoke({"document": document_text})
    logger.info("LLM chain invocation complete.")

    # 4. Clean and parse the output
    try:
        json_start = result_str.find('{')
        json_end = result_str.rfind('}') + 1
        if json_start != -1 and json_end != 0:
            json_str = result_str[json_start:json_end]
            logger.info("Successfully parsed JSON from LLM output.")
            return {"analysis": json_str}
        else:
            logger.warning("No JSON object found in LLM output.")
            return {"analysis": result_str}
    except Exception as e:
        logger.error(f"Error parsing LLM output: {e}", exc_info=True)
        return {"error": "Failed to parse analysis from the document.", "raw_output": result_str}

if __name__ == '__main__':
    # This is an example of how to use the function.
    # You would need a sample PDF file to test this.
    # For example, if you have a file named 'sample_bill.pdf' in the same directory:
    try:
        with open('sample_bill.pdf', 'rb') as f:
            content = f.read()
            analysis = analyze_energy_fact_sheet(content)
            logger.info(f"Analysis result: {analysis}")
    except FileNotFoundError:
        logger.error("Could not find 'sample_bill.pdf'. Please add a sample PDF to test.")
    except Exception as e:
        logger.error(f"An error occurred: {e}", exc_info=True)
