// Admin Edge Function: Update Celebrity Profile Images
// 연예인 프로필 이미지 URL 일괄 업데이트
// 보안: Service Role Key 필수

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

interface CelebrityImageUpdate {
  id: string
  profile_image_url: string
}

interface RequestBody {
  updates: CelebrityImageUpdate[]
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Service Role 인증
    const authHeader = req.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const token = authHeader.replace('Bearer ', '')
    if (token !== serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized. Service role key required.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey)

    // 2. 요청 파싱
    const body: RequestBody = await req.json()
    const { updates } = body

    if (!updates || !Array.isArray(updates) || updates.length === 0) {
      return new Response(
        JSON.stringify({ error: 'updates array required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`🖼️ 연예인 이미지 업데이트: ${updates.length}명`)

    // 3. 배치 업데이트
    const results: { id: string; success: boolean; error?: string }[] = []

    for (const update of updates) {
      try {
        // external_ids.profile_image 필드 업데이트
        const { data: celebrity, error: fetchError } = await supabase
          .from('celebrities')
          .select('id, name, external_ids')
          .eq('id', update.id)
          .single()

        if (fetchError || !celebrity) {
          results.push({ id: update.id, success: false, error: 'Celebrity not found' })
          continue
        }

        const currentExternalIds = celebrity.external_ids || {}
        const updatedExternalIds = {
          ...currentExternalIds,
          profile_image: update.profile_image_url
        }

        const { error: updateError } = await supabase
          .from('celebrities')
          .update({
            external_ids: updatedExternalIds,
            updated_at: new Date().toISOString()
          })
          .eq('id', update.id)

        if (updateError) {
          results.push({ id: update.id, success: false, error: updateError.message })
        } else {
          console.log(`  ✅ ${celebrity.name}: 이미지 URL 업데이트 완료`)
          results.push({ id: update.id, success: true })
        }

      } catch (error) {
        results.push({
          id: update.id,
          success: false,
          error: error instanceof Error ? error.message : String(error)
        })
      }
    }

    const successCount = results.filter(r => r.success).length

    return new Response(
      JSON.stringify({
        message: `Updated ${successCount}/${updates.length} celebrities`,
        results
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Admin Update Celebrity Images 오류:', error)
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unknown error'
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
