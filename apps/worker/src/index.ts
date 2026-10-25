// Worker entry point. Claude calls, transcription and scheduled jobs are added by their feature tasks.
import { health } from "./health.js";

console.log(JSON.stringify(health()));
