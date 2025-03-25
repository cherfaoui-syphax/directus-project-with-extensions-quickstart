<template>
  <div v-if="!collection" class="lp-body">
    <p>Bienvenue sur la page d'accueil.</p>
  </div>
  <div v-else-if="loading" class="lp-body">
    <p>Loading content...</p>
  </div>
  <div v-else-if="noData" class="lp-body">
    <p>Aucune donnée disponible.</p>
  </div>
  <div v-else class="lp-body ag-theme-alpine">
    <ag-grid-vue
      style="width: 100%; height: 500px"
      :columnDefs="columnDefs"
      :rowData="rowData"
      :defaultColDef="defaultColDef"
      :pagination="true"
      :paginationPageSize="10"
    />
  </div>
</template>

<script>
import { ref, watch, computed } from "vue";
import { useApi } from "@directus/extensions-sdk";
import { AgGridVue } from "ag-grid-vue3";
import { ModuleRegistry, ClientSideRowModelModule } from "ag-grid-community";
import "ag-grid-community/styles/ag-grid.css";
import "ag-grid-community/styles/ag-theme-alpine.css";

// Register the required module
ModuleRegistry.registerModules([ClientSideRowModelModule]);

export default {
  components: {
    AgGridVue,
  },
  props: {
    collection: {
      type: String,
      required: false,
      default: null,
    },
  },
  setup(props) {
    const api = useApi();
    const loading = ref(false);
    const rowData = ref([]);
    const columnDefs = ref([]);
    const defaultColDef = ref({
      sortable: true,
      filter: true,
      resizable: true,
      flex: 1,
      minWidth: 100,
    });

    const noData = computed(() => {
      return props.collection && rowData.value.length === 0 && !loading.value;
    });

    // Watch for collection changes
    watch(
      () => props.collection,
      (newCollection) => {
        if (newCollection) {
          fetchCollectionData(newCollection);
        } else {
          // Reset data when on home page
          rowData.value = [];
          columnDefs.value = [];
        }
      },
      { immediate: true }
    );

    async function fetchCollectionData(collection) {
      if (!collection) return;

      loading.value = true;
      rowData.value = [];
      columnDefs.value = [];

      try {
        const { data } = await api.get(`/items/${collection}`);

        if (data.data && data.data.length) {
          // Create column definitions from the first row
          const firstRow = data.data[0];
          columnDefs.value = Object.keys(firstRow).map((key) => ({
            field: key,
            headerName:
              key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, " "),
            // Handle special cases for different data types
            cellRenderer: (params) => {
              if (params.value === null || params.value === undefined) {
                return "-";
              } else if (typeof params.value === "object") {
                return JSON.stringify(params.value);
              }
              return params.value;
            },
          }));

          // Set row data
          rowData.value = data.data;
        }
      } catch (error) {
        console.error("Error fetching collection data:", error);
      } finally {
        loading.value = false;
      }
    }

    return {
      loading,
      rowData,
      columnDefs,
      defaultColDef,
      noData,
    };
  },
};
</script>

<style scoped>
.lp-body {
  padding: var(--content-padding);
  background: var(--background-light);
  border-radius: var(--border-radius);
}

/* Ensure AG Grid styles are applied correctly */
:deep(.ag-header-cell-label) {
  font-weight: bold;
}

:deep(.ag-row) {
  border-bottom: 1px solid var(--border-normal);
}

:deep(.ag-theme-alpine) {
  --ag-background-color: transparent;
  --ag-odd-row-background-color: rgba(0, 0, 0, 0.05);
}
</style>
