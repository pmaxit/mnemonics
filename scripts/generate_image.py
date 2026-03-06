import os
import sys
import argparse
from dotenv import load_dotenv

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("Please install google-genai package: pip install google-genai")
    sys.exit(1)

def generate_image_for_word(word):
    # Load environment variables (expecting GEMINI_API_KEY)
    load_dotenv()
    
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY not found in .env or environment variables.")
        sys.exit(1)
        
    print(f"Generating image for word: '{word}' using Nano Banana (gemini-2.5) model...")
    
    # Initialize the client
    client = genai.Client(api_key=api_key)
    
    try:
        # Construct a prompt for a vocabulary word
        prompt = (
            f"Create a 4-panel comic strip (four rectangular panels in a grid) that tells a short, realistic "
            f"story to explain the vocabulary word '{word}'. The comic should visually depict a scene and realistic "
            f"usage of the word '{word}' to help someone remember its meaning. Use a clear, engaging comic book style. "
            f"Do not include any text or speech bubbles in the images."
        )
        
        # Use the nano banana model (gemini-2.5-flash-image)
        # Note: gemini-2.5 models use generate_content, not generate_images
        result = client.models.generate_content(
            model='gemini-2.5-flash-image',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_modalities=["IMAGE"],
            )
        )
        
        if not result.candidates or not result.candidates[0].content.parts:
            print("No image was generated.")
            return

        # Prepare output directory
        output_dir = "assets/generated_images"
        os.makedirs(output_dir, exist_ok=True)
        
        output_file = os.path.join(output_dir, f"{word.lower().replace(' ', '_')}.jpg")
        
        # Save the image
        part = result.candidates[0].content.parts[0]
        if hasattr(part, 'inline_data') and part.inline_data:
            image_bytes = part.inline_data.data
            with open(output_file, 'wb') as f:
                f.write(image_bytes)
            print(f"Successfully saved image for '{word}' to: {output_file}")
        else:
            print("No image data found in response parts.")
            
    except Exception as e:
        print(f"Error generating image: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate an image for a vocabulary word using the Nano Banana model")
    parser.add_argument("word", help="The vocabulary word to generate an image for")
    
    args = parser.parse_args()
    generate_image_for_word(args.word)
