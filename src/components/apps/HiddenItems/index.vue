<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { NButton, NCard, NCheckbox, NEllipsis, NGrid, NGridItem, NSpin, useDialog, useMessage } from 'naive-ui'
import { deletes as deleteItems, edit as editItem, getListByGroupId } from '@/api/panel/itemIcon'
import { getList as getGroupList } from '@/api/panel/itemIconGroup'
import { ItemIcon } from '@/components/common'
import { t } from '@/locales'

interface HiddenGroup {
  id?: number
  title?: string
  items: Panel.ItemInfo[]
}

const groups = ref<HiddenGroup[]>([])
const loading = ref(false)
const restoring = ref(false)
const deleting = ref(false)
const selectedIds = ref<number[]>([])
const ms = useMessage()
const dialog = useDialog()

const total = computed(() => groups.value.reduce((sum, group) => sum + group.items.length, 0))

async function getHiddenItems() {
  loading.value = true
  try {
    const { code, data } = await getGroupList<Common.ListResponse<Panel.ItemIconGroup[]>>()
    if (code !== 0) {
      ms.error(t('apps.hiddenItems.getListFail'))
      return
    }

    const hiddenGroups: HiddenGroup[] = []
    for (const group of data.list) {
      const res = await getListByGroupId<Common.ListResponse<Panel.ItemInfo[]>>(group.id)
      if (res.code === 0) {
        const hiddenItems = (res.data.list || []).filter(item => item.isHide)
        if (hiddenItems.length > 0)
          hiddenGroups.push({ id: group.id, title: group.title, items: hiddenItems })
      }
    }

    groups.value = hiddenGroups
    selectedIds.value = selectedIds.value.filter(id => hiddenGroups.some(group => group.items.some(item => item.id === id)))
  }
  catch (error) {
    ms.error(t('apps.hiddenItems.getListFail'))
  }
  loading.value = false
}

function isSelected(id?: number) {
  return id !== undefined && selectedIds.value.includes(id)
}

function handleSelect(id: number | undefined, checked: boolean) {
  if (id === undefined)
    return
  if (checked) {
    if (!selectedIds.value.includes(id))
      selectedIds.value.push(id)
  }
  else {
    selectedIds.value = selectedIds.value.filter(item => item !== id)
  }
}

// 点击整张卡片切换选中状态
function toggleItem(id?: number) {
  if (id === undefined)
    return
  handleSelect(id, !isSelected(id))
}

function isGroupAllSelected(group: HiddenGroup) {
  return group.items.length > 0 && group.items.every(item => isSelected(item.id))
}

function isGroupIndeterminate(group: HiddenGroup) {
  const selectedCount = group.items.filter(item => isSelected(item.id)).length
  return selectedCount > 0 && selectedCount < group.items.length
}

function handleGroupSelect(group: HiddenGroup, checked: boolean) {
  const ids = group.items.map(item => item.id).filter((id): id is number => id !== undefined)
  if (checked) {
    for (const id of ids) {
      if (!selectedIds.value.includes(id))
        selectedIds.value.push(id)
    }
  }
  else {
    selectedIds.value = selectedIds.value.filter(id => !ids.includes(id))
  }
}

function getSelectedItems(): Panel.ItemInfo[] {
  const items: Panel.ItemInfo[] = []
  for (const group of groups.value) {
    for (const item of group.items) {
      if (item.id !== undefined && selectedIds.value.includes(item.id))
        items.push(item)
    }
  }
  return items
}

async function handleBatchRestore() {
  const items = getSelectedItems()
  if (items.length === 0)
    return

  restoring.value = true
  try {
    const results = await Promise.all(items.map(item => editItem<Panel.ItemInfo>({ ...item, isHide: false })))
    if (results.every(res => res.code === 0)) {
      ms.success(t('apps.hiddenItems.restoreSuccess'))
      selectedIds.value = []
      await getHiddenItems()
      window.dispatchEvent(new Event('sun-panel:refresh-items'))
    }
    else {
      ms.error(t('common.failed'))
    }
  }
  catch (error) {
    ms.error(t('common.failed'))
  }
  restoring.value = false
}

function handleBatchDelete() {
  if (selectedIds.value.length === 0)
    return

  dialog.warning({
    title: t('common.warning'),
    content: t('apps.hiddenItems.deleteWarnText', { count: selectedIds.value.length }),
    positiveText: t('common.confirm'),
    negativeText: t('common.cancel'),
    onPositiveClick: async () => {
      deleting.value = true
      try {
        const { code, msg } = await deleteItems(selectedIds.value)
        if (code === 0) {
          ms.success(t('common.deleteSuccess'))
          selectedIds.value = []
          await getHiddenItems()
          window.dispatchEvent(new Event('sun-panel:refresh-items'))
        }
        else {
          ms.error(`${t('common.deleteFail')}:${msg}`)
        }
      }
      catch (error) {
        ms.error(t('common.deleteFail'))
      }
      deleting.value = false
    },
  })
}

onMounted(() => {
  getHiddenItems()
})
</script>

<template>
  <div class="h-full flex flex-col">
    <div class="p-2">
      <NButton type="success" size="small" style="margin-right: 10px;" :disabled="selectedIds.length === 0" :loading="restoring" @click="handleBatchRestore">
        {{ $t('apps.hiddenItems.batchRestore') }}
      </NButton>
      <NButton type="error" size="small" :disabled="selectedIds.length === 0" :loading="deleting" @click="handleBatchDelete">
        {{ $t('apps.hiddenItems.batchDelete') }}
      </NButton>
    </div>

    <div class="flex-1 overflow-auto bg-slate-200 dark:bg-zinc-900 rounded-xl p-2">
      <NSpin :show="loading" size="small">
        <div v-if="!loading && total === 0" class="flex justify-center mt-10 text-slate-500">
          {{ $t('apps.hiddenItems.nothingText') }}
        </div>

        <div v-for="group in groups" :key="group.id" class="mt-4 first:mt-0">
          <div class="flex items-center mb-2">
            <NCheckbox
              :checked="isGroupAllSelected(group)"
              :indeterminate="isGroupIndeterminate(group)"
              @update:checked="handleGroupSelect(group, $event)"
            />
            <span class="font-bold ml-2">{{ group.title }}</span>
          </div>
          <NGrid cols="1 300:2 600:3 900:4" :x-gap="8" :y-gap="8">
            <NGridItem v-for="item in group.items" :key="item.id">
              <NCard size="small" style="border-radius: 8px;" class="cursor-pointer" @click="toggleItem(item.id)">
                <div class="flex items-center">
                  <NCheckbox :checked="isSelected(item.id)" @update:checked="handleSelect(item.id, $event)" @click.stop />
                  <ItemIcon :item-icon="item.icon" :size="28" class="ml-2 overflow-hidden rounded-md shrink-0" />
                  <div class="ml-2 min-w-0 flex-1">
                    <NEllipsis class="text-sm">
                      {{ item.title }}
                    </NEllipsis>
                  </div>
                </div>
              </NCard>
            </NGridItem>
          </NGrid>
        </div>
      </NSpin>
    </div>
  </div>
</template>
