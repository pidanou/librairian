import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { HfInference } from "https://esm.sh/@huggingface/inference@2.3.2";

console.log("Hello from `huggingface-image-captioning` function!");

// TODO: TO CHANGE !
const hf = new HfInference("");

serve(async (req) => {
  const payload = await req.json();
  const binaryData = atob(payload.bytes);
  const byteArray = new Uint8Array(binaryData.length);
  for (let i = 0; i < binaryData.length; i++) {
    byteArray[i] = binaryData.charCodeAt(i);
  }
  const blob = new Blob([byteArray]);
  // Run image captioning with Huggingface
  const imgDesc = await hf.imageToText({
    data: blob,
    model: "nlpconnect/vit-gpt2-image-captioning",
  });
  console.log(imgDesc.generated_text);
  return new Response(imgDesc.generated_text);
});
