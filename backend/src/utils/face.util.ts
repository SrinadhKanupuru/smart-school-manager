import axios from "axios";
import FormData from "form-data";

const PYTHON_AI_URL = process.env.PYTHON_AI_URL || "http://localhost:8000/extract-embedding";

export const processFace = async (imageBuffer: Buffer) => {
  try {
    const formData = new FormData();
    formData.append("file", imageBuffer, {
      filename: "face_scan.jpg",
      contentType: "image/jpeg",
    });

    const response = await axios.post(PYTHON_AI_URL, formData, {
      headers: formData.getHeaders(),
    });

    const embedding = response.data.embedding;
    const blinkDetected = response.data.blinkDetected ?? true;

    return { embedding, blinkDetected };
  } catch (error: any) {
    console.error(
      "❌ Failed to get embedding from Python:",
      error.response?.data || error.message,
    );
    return null;
  }
};
