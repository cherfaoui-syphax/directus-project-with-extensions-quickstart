<template>
  <private-view :title="pageTitle">
    <template v-if="breadcrumb" #headline>
      <v-breadcrumb :items="breadcrumb" />
    </template>

    <template #navigation>
      <page-navigation :current="page" :pages="allPages" />
    </template>

    <div class="lp-container">
      <page-banner v-if="pageBanner" :src="pageBanner" />
      <page-content :collection="currentCollection" />
    </div>

    <router-view name="landing-page" :page="page" />
  </private-view>
</template>

<script>
import { ref, watch, onMounted, computed } from "vue";
import { useApi } from "@directus/extensions-sdk";
import { useRouter } from "vue-router";
import PageNavigation from "./components/navigation.vue";
import PageBanner from "./components/PageBanner.vue";
import PageContent from "./components/PageContent.vue";
import useDirectusToken from "./use-directus-token.js";

export default {
  components: {
    PageNavigation,
    PageBanner,
    PageContent,
  },
  props: {
    page: {
      type: String,
      default: "home",
    },
  },
  setup(props) {
    const router = useRouter();
    const api = useApi();
    const { addTokenToURL } = useDirectusToken(api);

    const pageTitle = ref("");
    const pageBanner = ref("");
    const breadcrumb = ref([{ name: "Home", to: `/landing-page` }]);
    const allPages = ref([]);
    const currentCollection = ref(null);

    onMounted(fetchAllPages);

    watch(
      () => props.page,
      () => renderPage(props.page)
    );

    function changePage(to) {
      router.push(to);
    }

    async function fetchAllPages() {
      try {
        const { data } = await api.get("/collections");
        allPages.value = data.data
          .filter(c => !c.collection.startsWith("directus_"))
          .map(c => ({
            label: c.collection.replace(/_/g, " ").toUpperCase(),
            uri: c.collection,
            to: `/landing-page/${c.collection}`,
            icon: "folder",
            color: "#3498db",
          }));
        renderPage(props.page);
      } catch (error) {
        console.error("Error fetching collections:", error);
      }
    }

    async function renderPage(page) {
      try {
        if (!page || page === "home") {
          pageTitle.value = "Home de los hombres";
          pageBanner.value = addTokenToURL("/assets/home-banner.jpg?width=2000&height=563&fit=cover");
          currentCollection.value = null; // No collection for home page
          return;
        }

        const table = allPages.value.find(p => p.uri === page);
        if (!table) {
          pageTitle.value = "404: Not Found";
          currentCollection.value = null;
          return;
        }

        pageTitle.value = table.label;
        pageBanner.value = addTokenToURL("/assets/default-banner.jpg?width=2000&height=563&fit=cover");
        currentCollection.value = page; // Set the current collection for PageContent

        breadcrumb.value[1] = { name: table.label, to: `/landing-page/${page}` };
      } catch (error) {
        console.error("Erreur lors du rendu de la page:", error);
      }
    }

    return {
      pageTitle,
      pageBanner,
      breadcrumb,
      allPages,
      changePage,
      currentCollection,
    };
  },
};
</script>

<style>
.lp-container {
  padding: var(--content-padding);
  padding-top: 0;
  width: 100%;
  max-width: 1024px;
}

.lp-container > div {
  margin-bottom: var(--content-padding);
}

.lp-banner {
  border-radius: var(--border-radius);
  overflow: hidden;
}

.lp-banner img {
  display: block;
  width: 100%;
}
</style>