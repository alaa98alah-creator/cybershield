const VT_API_BASE = 'https://www.virustotal.com/api/v3'

export interface VTResultData {
  malicious_count: number
  suspicious_count: number
  harmless_count: number
  undetected_count: number
  vt_permalink: string
  raw_json: string
}

export async function submitUrlScan(
  targetUrl: string,
  apiKey: string,
): Promise<string> {
  const response = await fetch(`${VT_API_BASE}/urls`, {
    method: 'POST',
    headers: {
      'x-apikey': apiKey,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: `url=${encodeURIComponent(targetUrl)}`,
  })

  if (!response.ok) {
    const errText = await response.text()
    throw new Error(`VirusTotal URL scan failed: ${response.status} ${errText}`)
  }

  const data = (await response.json()) as {
    data: { id: string; type: string }
  }
  return data.data.id
}

export async function getUrlAnalysis(
  analysisId: string,
  apiKey: string,
): Promise<{ status: string; result: VTResultData | null }> {
  const response = await fetch(`${VT_API_BASE}/analyses/${analysisId}`, {
    headers: { 'x-apikey': apiKey },
  })

  if (!response.ok) {
    return { status: 'failed', result: null }
  }

  const data = (await response.json()) as {
    data: {
      id: string
      attributes: {
        stats: {
          malicious: number
          suspicious: number
          harmless: number
          undetected: number
          timeout: number
        }
        status: string
      }
    }
  }

  const attrs = data.data.attributes
  const stats = attrs.stats

  if (attrs.status === 'queued' || attrs.status === 'in-progress') {
    return { status: 'scanning', result: null }
  }

  return {
    status: 'completed',
    result: {
      malicious_count: stats.malicious,
      suspicious_count: stats.suspicious,
      harmless_count: stats.harmless,
      undetected_count: stats.undetected,
      vt_permalink: `https://www.virustotal.com/gui/analysis/${analysisId}`,
      raw_json: JSON.stringify(attrs),
    },
  }
}

export async function submitFileScan(
  fileBuffer: ArrayBuffer,
  fileName: string,
  apiKey: string,
): Promise<string> {
  const formData = new FormData()
  formData.append('file', new File([fileBuffer], fileName))

  const response = await fetch(`${VT_API_BASE}/files`, {
    method: 'POST',
    headers: { 'x-apikey': apiKey },
    body: formData,
  })

  if (!response.ok) {
    const errText = await response.text()
    throw new Error(
      `VirusTotal file scan failed: ${response.status} ${errText}`,
    )
  }

  const data = (await response.json()) as {
    data: { id: string }
  }
  return data.data.id
}

export async function getFileReport(
  fileHash: string,
  apiKey: string,
): Promise<VTResultData | null> {
  const response = await fetch(`${VT_API_BASE}/files/${fileHash}`, {
    headers: { 'x-apikey': apiKey },
  })

  if (response.status === 404 || !response.ok) {
    return null
  }

  const data = (await response.json()) as {
    data: {
      id: string
      attributes: {
        last_analysis_stats: {
          malicious: number
          suspicious: number
          harmless: number
          undetected: number
          timeout: number
        }
        sha256: string
      }
    }
  }

  const stats = data.data.attributes.last_analysis_stats

  return {
    malicious_count: stats.malicious,
    suspicious_count: stats.suspicious,
    harmless_count: stats.harmless,
    undetected_count: stats.undetected,
    vt_permalink: `https://www.virustotal.com/gui/file/${data.data.attributes.sha256}`,
    raw_json: JSON.stringify(data.data.attributes),
  }
}