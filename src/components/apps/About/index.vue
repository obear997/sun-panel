<script setup lang="ts">
import { NGradientText } from 'naive-ui'
import { onMounted, ref } from 'vue'
import { get } from '@/api/system/about'
import srcSvglogo from '@/assets/logo.svg'

interface Version {
  versionName: string
  versionCode: number
}

const versionName = ref('')

onMounted(() => {
  get<Version>().then((res) => {
    if (res.code === 0)
      versionName.value = res.data.versionName
  })
})
</script>

<template>
  <div class="min-h-full flex flex-col justify-center py-5">
    <div class="flex flex-col items-center justify-center">
      <img :src="srcSvglogo" width="100" height="100" alt="">
      <div class="text-3xl font-semibold">
        {{ $t('common.appName') }}
      </div>
      <div class="text-xl">
        <NGradientText type="info">
          <a href="https://github.com/obear997/sun-panel/releases" class="font-semibold" :title="$t('apps.about.viewUpdateLog')" target="_blank">v{{ versionName }}</a>
        </NGradientText>
      </div>
      <div class="mt-2">
        <a href="https://github.com/obear997/sun-panel/releases" target="_blank" class="link">{{ $t('apps.about.checkUpdate') }}</a>
      </div>
    </div>
  </div>
</template>

<style>
.link{
    color:rgb(0, 89, 255)
}
</style>
