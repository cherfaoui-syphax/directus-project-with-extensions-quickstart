<template>
    <div class="lp-banner" v-if="banner">
      <img :src="banner" alt="Page Banner" />
    </div>
  </template>
  
  <script>
  export default {
    props: {
      banner: {
        type: String,
        required: false,
        default: "",
      },
    },
  };
  </script>
  
  <style scoped>
  .lp-banner {
    border-radius: var(--border-radius);
    overflow: hidden;
  }
  
  .lp-banner img {
    display: block;
    width: 100%;
  }
  </style>
  