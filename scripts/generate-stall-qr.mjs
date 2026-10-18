import { writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
import QRCode from "qrcode";

const URL = "https://klbdesigns.art/m";
const OUT = path.join(
	path.dirname(fileURLToPath(import.meta.url)),
	"..",
	"public",
	"stall-qr.svg",
);

const svg = await QRCode.toString(URL, {
	type: "svg",
	errorCorrectionLevel: "Q",
	margin: 4,
	color: { dark: "#000000", light: "#ffffff" },
});

await writeFile(OUT, svg);
console.log(`Wrote ${OUT}`);
