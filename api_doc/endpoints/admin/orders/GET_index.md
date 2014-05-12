# GET api/admin/orders

Returns a list of all orders and the order lines they contain.

## Example

### Request

`https://zmey.co.uk/api/admin/orders`

### Response

```json
{
  "orders":[
    {
      "order":{
        "id":1,
        "user_id":1,
        "order_number":"20140411-AX0W",
        "email_address":"shopper@example.org",
        "full_name":"Alice Shopper",
        "address_line_1":"My Street",
        "address_line_2":"",
        "town_city":"London",
        "county":"",
        "postcode":"L0N D0N",
        "country_id":1,
        "phone_number":"",
        "shipping_amount":"0.0",
        "shipping_method":"Standard Shipping",
        "status":1,
        "total":"350.0",
        "created_at":"2014-04-11T10:00:00.000+01:00",
        "updated_at":"2014-04-11T10:00:00.000+01:00",
        "website_id":1,
        "basket_id":1,
        "preferred_delivery_date":null,
        "preferred_delivery_date_prompt":null,
        "preferred_delivery_date_format":null,
        "ip_address":"127.0.0.1",
        "customer_notes": "Please leave parcel with neighbour if nobody is in."
      },
      "order_lines":[
        {
          "id":1,
          "order_id":1,
          "product_id":1,
          "product_sku":"SKU",
          "product_name":"Trainers",
          "product_price":"50.0",
          "tax_amount":"0.0",
          "quantity":1,
          "created_at":"2014-04-11T10:00:00.000+01:00",
          "updated_at":"2014-04-11T10:00:00.000+01:00",
          "feature_descriptions":"",
          "shipped":1
        },
        {
          "id":2,
          "order_id":1,
          "product_id":2,
          "product_sku":"IDV13",
          "product_name":"iDevice",
          "product_price":"300.0",
          "tax_amount":"0.0",
          "quantity":1,
          "created_at":"2014-04-11T10:00:00.000+01:00",
          "updated_at":"2014-04-11T10:00:00.000+01:00",
          "feature_descriptions":"Storage: 16GB|Colour: Black",
          "shipped":0
        }
      ]
    }
  ]
}
```
