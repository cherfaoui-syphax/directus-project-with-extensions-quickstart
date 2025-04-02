<template>
  <div class="lp-container">
    <div v-if="!collection" class="lp-body empty-state">
      <p>Bienvenue sur la page d'accueil.</p>
    </div>
    <div v-else-if="loading" class="lp-body loading-state">
      <p>Chargement des données...</p>
    </div>
    <div v-else-if="noData" class="lp-body no-data-state">
      <p>Aucune donnée disponible.</p>
    </div>
    <div v-else class="lp-body ag-theme-alpine-dark">
      <ag-grid-vue
        class="custom-grid"
        style="width: 100%; height: 600px"
        :columnDefs="columnDefs"
        :rowData="rowData"
        :defaultColDef="defaultColDef"
        :pagination="true"
        :paginationPageSize="20"
        :rowSelection="'multiple'"
        :animateRows="true"
      />
    </div>
  </div>
</template>

<script>
import { ref, watch, computed } from "vue";
import { useApi } from "@directus/extensions-sdk";
import { AgGridVue } from "ag-grid-vue3";
import { ModuleRegistry, ClientSideRowModelModule } from "ag-grid-community";
import "ag-grid-community/styles/ag-grid.css";
import "ag-grid-community/styles/ag-theme-alpine.css";

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
      minWidth: 120,
      cellStyle: { textAlign: "center", fontSize: "14px", borderRight: "1px solid #444" },
    });

    const noData = computed(() => props.collection && rowData.value.length === 0 && !loading.value);

    watch(
      () => props.collection,
      (newCollection) => {
        if (newCollection) {
          fetchCollectionData(newCollection);
        } else {
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
          const firstRow = data.data[0];
          columnDefs.value = Object.keys(firstRow).map((key) => ({
            field: key,
            headerName: key.replace(/_/g, " ").toUpperCase(),
            wrapText: true,
            autoHeight: true,
            cellRenderer: (params) => {
              if (params.value === null || params.value === undefined) return "-";
              if (typeof params.value === "object") return JSON.stringify(params.value);
              return params.value;
            },
          }));
          rowData.value = data.data;
        }
      } catch (error) {
        console.error("Erreur lors de la récupération des données :", error);
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
.lp-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background-color: var(--background-light);
  border-radius: var(--border-radius);
}

.lp-body {
  width: 100%;
  max-width: 1200px;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
}

.empty-state, .loading-state, .no-data-state {
  text-align: center;
  font-size: 18px;
  color: var(--text-muted);
  font-weight: bold;
}

.custom-grid {
  border-radius: 8px;
  overflow: hidden;
}

:deep(.ag-header-cell-label) {
  font-weight: bold;
  text-transform: uppercase;
  font-size: 12px;
  white-space: normal !important;
  text-align: center;
}

:deep(.ag-theme-alpine-dark) {
  --ag-header-background-color: #1e1e1e;
  --ag-background-color: #2b2b2b;
  --ag-border-color: #444;
  --ag-odd-row-background-color: rgba(255, 255, 255, 0.05);
  --ag-font-size: 14px;
}
</style>