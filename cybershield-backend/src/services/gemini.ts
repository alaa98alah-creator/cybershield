export interface GeminiAnalysis {
  risk_level: 'safe' | 'low' | 'medium' | 'high' | 'critical';
  simplified_summary: string;
  preventive_tips: string[];
}

export async function analyzeWithGemini(
  target: string,
  scanType: 'link' | 'file',
  vtResult: {
    malicious: number;
    suspicious: number;
    harmless: number;
    undetected: number;
    rawJson?: string;
  },
  env: { GEMINI_API_KEY: string }
): Promise<GeminiAnalysis> {
  const prompt = `أنت خبير أمن معلومات. حلل نتيجة فحص ${scanType === 'link' ? 'رابط' : 'ملف'} وقدم تقرير باللغة العربية.

الهدف: ${target}
نتيجة VirusTotal:
- محركات اكتشفت تهديد: ${vtResult.malicious}
- محركات اكتشفت اشتباه: ${vtResult.suspicious}
- محركات اعتبرته آمن: ${vtResult.harmless}
- محركات لم تكتشف شيء: ${vtResult.undetected}
${vtResult.rawJson ? `التفاصيل التقنية: ${vtResult.rawJson.substring(0, 2000)}` : ''}

أجب بصيغة JSON فقط بدون أي نص إضافي:
{
  "risk_level": "safe أو low أو medium أو high أو critical",
  "simplified_summary": "شرح مبسط بالعربية لما وجدته",
  "preventive_tips": ["نصيحة 1", "نصيحة 2", "نصيحة 3"]
}`;

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${env.GEMINI_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.3,
          maxOutputTokens: 1024,
        },
      }),
    }
  );

  if (!response.ok) {
    throw new Error(`Gemini API error: ${response.status}`);
  }

  const data = (await response.json()) as {
    candidates: { content: { parts: { text: string }[] } }[];
  };

  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) {
    throw new Error('Empty Gemini response');
  }

  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) {
    throw new Error('Invalid Gemini response format');
  }

  const parsed = JSON.parse(jsonMatch[0]) as GeminiAnalysis;

  const validLevels = ['safe', 'low', 'medium', 'high', 'critical'];
  if (!validLevels.includes(parsed.risk_level)) {
    parsed.risk_level = 'medium';
  }

  return parsed;
}