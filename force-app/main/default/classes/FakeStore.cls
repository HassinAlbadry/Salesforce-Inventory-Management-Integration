public class FakeStore {
    public static void fetchProducts() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Fake_Store_API/products');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            // Parse the JSON response
            List<Product> products = (List<Product>) JSON.deserialize(response.getBody(), List<Product>.class);
            
            List<Fake_Store__c> prodsToInsert = new List<Fake_Store__c>();
            
            // Fetch existing product IDs from the custom object
            List<Fake_Store__c> existingProds = [SELECT id__c FROM Fake_Store__c];
            
            for(Product p : products) {
                Boolean exists = false;
                
                // Check if the product ID already exists
                for(Fake_Store__c existingProd : existingProds) {
                    if(p.id == existingProd.id__c) {
                        exists = true;
                        break;
                    }
                }
                
                if(!exists) {
                    // If the product ID does not exist, add it to the list of records to insert
                    Fake_Store__c newProd = new Fake_Store__c(
                        id__c = p.id,
                        title__c = p.title,
                        price__c = p.price,
                        description__c = p.description,
                        category__c = p.category,
                        image__c = p.image
                    );
                    prodsToInsert.add(newProd);
                }
            }
            
            // Insert the new products if there are any
            if(!prodsToInsert.isEmpty()) {
                insert prodsToInsert;
            }
           
        } else {
            System.debug('Error: ' + response.getStatus());
        }
    }
    
    // class to post products from salesforce to external fake store api
    @future(callout=true)
     public static void createProductInExternalAPI(Id productId) {
         
         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://fakestoreapi.com/products');
        request.setMethod('POST');
         
        // get the entire record that was just added by user in fake store sobject
       Fake_Store__c product = [SELECT title__c, price__c, description__c, category__c, image__c FROM Fake_Store__c WHERE Id = :productId LIMIT 1];

        
        // Create the JSON payload
        String jsonBody = JSON.serialize(new ExternalProduct(product));
      
        HttpResponse response = http.send(request);
         
        
        if(response.getStatusCode() == 200) { // 200 Created
            System.debug('Product successfully created in external API.');
        } else {
            System.debug('Error: ' + response.getStatus());
        }
    }
    
    public class Product {
        public Integer id {get; set;}
        public String title {get; set;}
        public Double price {get; set;}
        public String description {get; set;}
        public String category {get; set;}
        public String image {get; set;}
    }
    
    
    //class to map pulled product to properties to send to api
     public class ExternalProduct {
        public String title;
        public Double price;
        public String description;
        public String image;
        public String category;
        
        public ExternalProduct(Fake_Store__c product) {
            this.title = product.title__c;
            this.price = product.price__c;
            this.description = product.description__c;
            this.image = product.image__c;
            this.category = product.category__c;
        }
    }
}