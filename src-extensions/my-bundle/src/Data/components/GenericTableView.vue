<template>
    <div>
      <h2>{{ title }}</h2>
      <ul>
        <li v-for="item in items" :key="item.id">
          {{ item }}
        </li>
      </ul>
    </div>
  </template>
  
  <script>
  export default {
    props: {
      title: String,
      items: Array,
    },
  };
  </script>
  