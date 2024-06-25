import { LightningElement, wire, track } from 'lwc';
import getInventoryItems from '@salesforce/apex/InventoryController.getInventoryItems';
import updateInventoryItem from '@salesforce/apex/InventoryController.updateInventoryItem';

const columns = [
    { label: 'Product id', fieldName: 'id__c' },
    { label: 'Product title', fieldName: 'title__c' },
    { label: 'Quantity', fieldName: 'quantity__c' },
    { label: 'Price', fieldName: 'price__c' },
    { type: 'button', typeAttributes: { label: 'Update', name: 'update' } }
];

export default class InventoryList extends LightningElement {
    @track inventoryItems;
    @track columns = columns;
    @track selectedItem;
    @track quantity;

    @wire(getInventoryItems)
    wiredInventory({ error, data }) {
        if (data) {
            this.inventoryItems = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleRowAction(event) {
        const { row } = event.detail;
        this.selectedItem = row;
       
        this.quantity = row.quantity__c;
    }

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    updateInventory() {
      
       
        updateInventoryItem({ itemId: this.selectedItem.id__c, newQuantity: this.quantity })
            .then(() => {
                this.selectedItem = null;
                return refreshApex(this.inventoryItems);
            })
            .catch(error => {
                console.error(error);
            });
    }
}
