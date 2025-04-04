<script lang="ts">
export default {
	inheritAttrs: false,
};
</script>

<script setup lang="ts">
import { useSync } from '@directus/extensions-sdk';
import { useI18n } from 'vue-i18n';

const props = withDefaults(
	defineProps<{
		collection: string;
		fieldGroups: Record<string, Record<string, any>[]>;
		groupTitleFields?: Record<string, any>[];
		groupField?: string | null;
		groupTitle?: string | null;
		isRelational?: boolean;
		imageSource?: string | null;
		titleField?: string | null;
		textField?: string | null;
		crop: boolean;
		dateField?: string | null;
		tagsField?: string | null;
		userField?: string | null;
		showUngrouped: boolean;
		showIndex: boolean;
		enableInfiniteScroll: boolean;
	}>(),
	{
		groupTitleFields: () => [],
		groupField: null,
		groupTitle: null,
		isRelational: true,
		imageSource: null,
		titleField: null,
		textField: null,
		dateField: null,
		tagsField: null,
		userField: null,
		showUngrouped: true,
		showIndex: true,
		enableInfiniteScroll: false,
	},
);

const emit = defineEmits([
	'update:imageSource',
	'update:titleField',
	'update:crop',
	'update:textField',
	'update:groupField',
	'update:groupTitle',
	'update:dateField',
	'update:tagsField',
	'update:userField',
	'update:showUngrouped',
	'update:showIndex'
]);

const { t } = useI18n();

const imageSourceSync = useSync(props, 'imageSource', emit);
const titleFieldSync = useSync(props, 'titleField', emit);
const cropSync = useSync(props, 'crop', emit);
const textFieldSync = useSync(props, 'textField', emit);
const showUngroupedSync = useSync(props, 'showUngrouped', emit);
const showIndexSync = useSync(props, 'showIndex', emit);
const groupFieldSync = useSync(props, 'groupField', emit);
const groupTitleSync = useSync(props, 'groupTitle', emit);
const dateFieldSync = useSync(props, 'dateField', emit);
const tagsFieldSync = useSync(props, 'tagsField', emit);
const userFieldSync = useSync(props, 'userField', emit);
</script>

<template>
	<div class="field">
		<div class="type-label">{{ t('layouts.kanban.group_field') }}</div>
		<v-select
			v-model="groupFieldSync"
			item-value="field"
			item-text="name"
			:items="fieldGroups.group"
			:placeholder="t('layouts.kanban.group_field_placeholder')"
		/>
	</div>

	<div v-if="groupFieldSync && isRelational" class="field">
		<div class="type-label">{{ t('layouts.kanban.group_title') }}</div>
		<v-select
			v-model="groupTitleSync"
			item-value="field"
			item-text="name"
			:items="groupTitleFields"
			:placeholder="t('layouts.kanban.group_title_placeholder')"
		/>
	</div>

	<div class="field">
		<div class="type-label">{{ t('layouts.kanban.title') }}</div>
		<v-select
			v-model="titleFieldSync"
			:items="fieldGroups.title"
			item-value="field"
			item-text="name"
			:placeholder="t('layouts.kanban.title_placeholder')"
			show-deselect
		/>
	</div>

	<div class="field">
		<div class="type-label">{{ t('layouts.kanban.text') }}</div>
		<v-select
			v-model="textFieldSync"
			:items="fieldGroups.text"
			item-value="field"
			item-text="name"
			:placeholder="t('layouts.kanban.text_placeholder')"
			show-deselect
		/>
	</div>

	<v-detail class="field">
		<template #title>{{ t('layouts.kanban.advanced') }}</template>

		<div class="nested-options">
			<!-- <div class="field">
				<div class="type-label">{{ t('layouts.kanban.tags') }}</div>
				<v-select
					v-model="tagsFieldSync"
					:items="fieldGroups.tags"
					item-value="field"
					item-text="name"
					:placeholder="t('layouts.kanban.tags_placeholder')"
					show-deselect
				/>
			</div> -->

			<div class="field">
				<div class="type-label">{{ t('layouts.kanban.date') }}</div>
				<v-select
					v-model="dateFieldSync"
					:items="fieldGroups.date"
					item-value="field"
					item-text="name"
					:placeholder="t('layouts.kanban.date_placeholder')"
					show-deselect
				/>
			</div>

			<div class="field">
				<div class="type-label">{{ t('layouts.kanban.image') }}</div>
				<v-select
					v-model="imageSourceSync"
					show-deselect
					item-value="field"
					item-text="name"
					:items="fieldGroups.file"
					:placeholder="t('layouts.kanban.image_placeholder')"
				/>
			</div>

			<div class="field">
				<div class="type-label">{{ t('layouts.kanban.image_fit') }}</div>
				<v-checkbox v-model="cropSync" block :label="t('layouts.kanban.crop')" />
			</div>
		<div class="field">
				<div class="type-label">{{ 'Show Index' }}</div>
				<v-checkbox v-model="showIndexSync" block label="Show" />
			</div>

			<div class="field">
				<div class="type-label">{{ t('layouts.kanban.user') }}</div>
				<v-select
					v-model="userFieldSync"
					:items="fieldGroups.user"
					item-value="field"
					item-text="name"
					:placeholder="t('layouts.kanban.user_placeholder')"
					show-deselect
				/>
			</div>

			<div class="field">
				<div class="type-label">{{ t('layouts.kanban.show_ungrouped') }}</div>
				<v-checkbox v-model="showUngroupedSync" block :label="t('layouts.kanban.show')" />
			</div>
			<!-- <div class="field">
				<div class="type-label">{{ 'Infinite Scroll' }}</div>
				<v-checkbox v-model="showUngroupedSync" block label="Enable" />
			</div> -->
		</div>
	</v-detail>
</template>

<style lang="scss" scoped>
.nested-options {
	display: grid;
	grid-template-columns: [start] minmax(0, 1fr) [half] minmax(0, 1fr) [full];
	gap: var(--theme--form--row-gap) var(--theme--form--column-gap);
}
</style>
