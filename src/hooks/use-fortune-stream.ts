"use client"

import * as React from "react"

export function useFortuneStream(endpoint: string, requestBody: any) {
  const [text, setText] = React.useState("")
  const [isLoading, setIsLoading] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)

  const startStream = React.useCallback(async () => {
    setIsLoading(true)
    setError(null)
    setText("")
    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(requestBody),
      })

      if (!response.ok || !response.body) {
        throw new Error("API 요청 실패")
      }

      const reader = response.body.getReader()
      const decoder = new TextDecoder()

      while (true) {
        const { done, value } = await reader.read()
        if (done) break
        const chunk = decoder.decode(value, { stream: true })
        setText((prev) => prev + chunk)
      }
    } catch (err: any) {
      setError(err.message || "스트리밍 중 오류 발생")
    } finally {
      setIsLoading(false)
    }
  }, [endpoint, requestBody])

  return { text, isLoading, error, startStream }
}
