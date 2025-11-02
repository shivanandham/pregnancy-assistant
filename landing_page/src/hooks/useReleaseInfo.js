import { useState, useEffect } from 'react'

const API_BASE_URL = import.meta.env.VITE_BACKEND_URL || '/api'

export const useReleaseInfo = () => {
  const [loading, setLoading] = useState(true)
  const [releaseInfo, setReleaseInfo] = useState(null)
  const [error, setError] = useState(null)

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  const fetchReleaseInfo = async () => {
    setLoading(true)
    setError(null)
    
    try {
      const response = await fetch(`${API_BASE_URL}/releases/qr`)
      const data = await response.json()

      if (data.success) {
        setReleaseInfo({
          ...data,
          formattedSize: formatFileSize(data.size)
        })
      } else {
        throw new Error(data.message || 'Failed to load release information')
      }
    } catch (err) {
      setError(err.message || 'Failed to load download information. Please try again later.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchReleaseInfo()
  }, [])

  return { loading, releaseInfo, error, refetch: fetchReleaseInfo }
}

