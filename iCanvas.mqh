<template>
  <div>
    <div class="items">
      <div class="user-items">
        <h3>User items</h3>
        <ul>
          <li v-for="item in userItems" :key="item.id" @click="selectUserItem(item)">
            {{ item.name }}
          </li>
        </ul>
      </div>
      <div class="available-items">
        <h3>Available items</h3>
        <ul>
          <li v-for="item in availableItems" :key="item.id" @click="selectAvailableItem(item)">
            {{ item.name }}
          </li>
        </ul>
      </div>
    </div>
    <div class="selected-items">
      <div class="user-selected-items">
        <h3>Selected user items</h3>
        <ul>
          <li v-for="(item, index) in selectedUserItems" :key="item.id">
            {{ item.name }}
            <button @click="removeSelectedUserItem(index)">Remove</button>
          </li>
        </ul>
      </div>
      <div class="available-selected-item">
        <h3>Selected available item</h3>
        <ul>
          <li v-if="selectedAvailableItem" :key="selectedAvailableItem.id">
            {{ selectedAvailableItem.name }}
            <button @click="removeSelectedAvailableItem()">Remove</button>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style>
/* Общие стили */

* {
    box-sizing: border-box;
  }
  
  body {
    margin: 0;
    padding: 0;
    font-family: Arial, sans-serif;
  }
  
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    grid-gap: 20px;
  }
  
  /* Стили для блока слева */
  
  .user-items {
    padding: 10px;
    background-color: #f2f2f2;
    border-radius: 5px;
    cursor: pointer;
  }
  
  .user-items ul {
    list-style-type: none;
    margin: 0;
    padding: 0;
  }
  
  .user-items li {
    padding: 5px;
  }
  
  .user-items li:hover {
    background-color: #ddd;
  }
  
  /* Стили для блока справа */
  
  .available-items {
    padding: 10px;
    background-color: #f2f2f2;
    border-radius: 5px;
    cursor: pointer;
  }
  
  .available-items ul {
    list-style-type: none;
    margin: 0;
    padding: 0;
  }
  
  .available-items li {
    padding: 5px;
  }
  
  .available-items li:hover {
    background-color: #ddd;
  }
  
  /* Стили для блока выбранных элементов */
  
  .selected-items {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    grid-gap: 10px;
  }
  
  .selected-items .user-selected-items,
  .selected-items .available-selected-item {
    padding: 10px;
    background-color: #f2f2f2;
    border-radius: 5px;
    cursor: pointer;
  }
  
  .selected-items h3 {
    margin: 0;
  }
  
  .selected-items ul {
    list-style-type: none;
    margin: 0;
    padding: 0;
  }
  
  .selected-items li {
    padding: 5px;
  }
  
  .selected-items li:hover {
    background-color: #ddd;
  }
  
  /* Стили для выбранной вещи */
  
  .selected-item {
    padding: 10px;
    background-color: #f2f2f2;
    border-radius: 5px;
    cursor: pointer;
  }
  </style>
<script>
export default {
  data() {
    return {
      userItems: [
        { id: 1, name: 'Shoes 1' },
        { id: 2, name: 'Shoes 2' },
        { id: 3, name: 'Shoes 3' },
        { id: 4, name: 'Shoes 4' },
        { id: 5, name: 'T-shirt 1' },
        { id: 6, name: 'T-shirt 2' },
        { id: 7, name: 'T-shirt 3' },
        { id: 8, name: 'T-shirt 4' },
      ],
      availableItems: [
        { id: 11, name: 'Jacket 1' },
        { id: 12, name: 'Jacket 2' },
        { id: 13, name: 'Jacket 3' },
        { id: 14, name: 'Jacket 4' },
        { id: 15, name: 'Hoodie 1' },
        { id: 16, name: 'Hoodie 2' },
        { id: 17, name: 'Hoodie 3' },
        { id: 18, name: 'Hoodie 4' },
      ],
      selectedUserItems: [],
      selectedAvailableItem: null,
    };
  },
  methods: {
    selectUserItem(item) {
      if (this.selectedUserItems.length < 6 && !this.selectedUserItems.includes(item)) {
        this.selectedUserItems.push(item);
      }
    },
    selectAvailableItem(item) {
      this.selectedAvailableItem = item;
    },
    removeSelectedUserItem(index) {
      this.selectedUserItems.splice(index, 1);
    },
    removeSelectedAvailableItem() {
      this.selectedAvailableItem = null;
    },
  },
};
</script>

