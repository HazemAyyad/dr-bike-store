# DoctorBike Store API endpoints

Source Flutter app:

- Base URL: `https://mjsall-001-site1.jtempurl.com`
- API client: `lib/core/api_client.dart`
- Constants: `lib/core/constants/app_constants.dart`

Old backend source:

- `C:\Users\hp\Downloads\Compressed\DoctorBike\DoctorBike\DoctorBike`
- ASP.NET Core controllers use route style:
  - `[Route("[controller]")]` => `/ControllerName/Action`
  - `[Route("api/[controller]")]` => `/api/ControllerName/Action`

## Endpoints used by the Flutter app

These are the routes the current Flutter app actually calls. Recreate these first in Laravel if the goal is to make the app run unchanged.

| Feature | Method used by Flutter | Endpoint | Auth | Main params/body |
|---|---:|---|---|---|
| Login | POST | `/Auth/login` | No | body: `email`, `password`, `userToken` |
| Register | POST | `/Users/Register` | No | body: `email`, `password`, `confirmPassword`, `dateAdd`, `userUpdate`, `dateUpdate` |
| Check active user | POST | `/Auth/CheckUser?UserId={id}` | Bearer | query: `UserId` |
| Forgot password | POST | `/Auth/ForgotPassword?Email={email}` | No | query: `Email` |
| Change password | POST | `/Auth/ChangePassword` | Bearer | body: `userId`, `oldPassword`, `newPassword`, `confirmPassword`, `userUpdate`, `dateUpdate` |
| Reset forgot password | PATCH | `/Auth/ChangePasswordToForgot` | No | body: `userId`, `newPassword`, `confirmPassword`, `userUpdate`, `dateUpdate` |
| Get user | POST | `/Users/GetById?id={id}` | Bearer | query: `id`; body: list criteria |
| Edit user | POST | `/Users/Edit` | Bearer | body: `id`, `email`, `phoneNumber`, `address`, `block`, `fullName`, `phoneNumber2`, `typeUser`, `userUpdate`, `dateUpdate`, `cityId` |
| Delete/block account | POST | `/Users/BlockUserAndNotActive?userId={id}` | Bearer | query: `userId` |
| App setting/contact | POST | `/Settings/CheckSetting` | No | no body in Flutter |
| Home main categories | POST | `/MainCategorys/GetAllShowMainCategories` | No | body: list criteria |
| Online ads | POST | `/OnlineAds/GetAllAds` | No | body: list criteria |
| More-sales items | POST | `/Items/GetAllItemIsMoreSales` | No | body: list criteria with item relations |
| Search items | POST | `/Items/GetAllItemByName?Name={name}&language={lang}` | No | query: `Name`, `language`; body: list criteria |
| Items by main category | POST | `/Items/GetAllItemsShowByMainCategory?MainCategory={id}` | No | query: `MainCategory`; body: list criteria |
| Item details | POST | `/Items/GetItemById?itemId={id}` | No | query: `itemId`; body: list criteria |
| Items by subcategory | POST | `/Items/GetAllShowItemsBySupCatId?supCategoryId={id}` | No | query: `supCategoryId`; body: list criteria |
| Show subcategories | POST | `/SupCategorys/GetAllShowSupCategories?mainCategoryId={id}` | No | query: `mainCategoryId`; body: list criteria |
| Item comments | POST | `/api/Comments/GetAllCommentsToItem?ItemId={id}` | No | query: `ItemId`; body: list criteria |
| Add/edit comment | POST | `/api/Comments/ManageComment` | Bearer | body: `id`, `comment`, `productId`, `productName`, `rate`, `userName`, `userAddId`, `isShow`, `dateAdd` |
| Notifications | POST | `/api/Notifications/GetNotifications?UserId={id}` | Bearer | query: `UserId`; body: list criteria |
| Mark notification read | POST | `/api/Notifications/EditNotification?NotificationId={id}&IsRead=true` | Bearer | query: `NotificationId`, `IsRead`; body: list criteria |
| Cities | POST | `/Cities/GetAllCities` | Bearer in account/checkout flows | body: list criteria |
| Discount code | POST | `/DiscoundCodes/GetByDiscoundCode?code={code}&userid={id}` | Bearer | query: `code`, `userid`; body: list criteria |
| User orders | POST | `/Orders/GetAllOrdersByUserId?statusOrder={status}&userId={id}` | Bearer | query: `statusOrder`, `userId`; body: list criteria |
| Create/edit order | POST | `/Orders/ManageOrder` | Bearer | body: order object from cart/checkout |

## Common request body used for list endpoints

Most list/read endpoints send a criteria object like this:

```json
{
  "listRelatedObjects": ["<string>", "<string>"],
  "entity": {"nullable": true},
  "listOrderOptions": ["<string>", "<string>"],
  "paginationInfo": {"pageIndex": 0, "pageSize": 0}
}
```

For product lists/details, Flutter usually asks for:

```json
{
  "listRelatedObjects": [
    "ViewImgs",
    "NormalImgs",
    "_3DImgs",
    "SupCategories",
    "ItemSizes",
    "ItemColor"
  ],
  "entity": {"nullable": true},
  "listOrderOptions": ["<string>", "<string>"],
  "paginationInfo": {"pageIndex": 0, "pageSize": 0}
}
```

For orders, Flutter asks for:

```json
{
  "listRelatedObjects": [
    "ViewImgs",
    "NormalImgs",
    "_3DImgs",
    "SupCategories",
    "ItemSize",
    "ItemColor",
    "OrderDetails"
  ],
  "entity": {"nullable": true},
  "listOrderOptions": ["<string>", "<string>"],
  "paginationInfo": {"pageIndex": 0, "pageSize": 0}
}
```

## Controllers/endpoints available in the old ASP.NET backend

These exist in the old backend, even if the Flutter store app does not currently call all of them.

### Auth

- `POST /Auth/login`
- `POST /Auth/ChangePassword`
- `POST /Auth/ForgotPassword`
- `POST /Auth/CheckUser`
- `PATCH /Auth/ChangePasswordToForgot`

### Users

- `POST /Users/Register`
- `POST /Users/Edit`
- `POST /Users/GetAllUsers`
- `POST /Users/GetById`
- `DELETE /Users/Delete`
- `POST /Users/AddRoleToUser`
- `POST /Users/RemoveRoleFromUser`
- `POST /Users/GetAllUserBlock`
- `POST /Users/BlockUserAndNotActive`

### MainCategorys

- `POST /MainCategorys/ManageMainCategory`
- `POST /MainCategorys/GetAllMainCategory`
- `POST /MainCategorys/GetMainCategoryById`
- `DELETE /MainCategorys/DeleteMainCategory`
- `POST /MainCategorys/GetAllShowMainCategories`

### SupCategorys

- `POST /SupCategorys/ManageSupCategory`
- `POST /SupCategorys/GetSupCategoriesByIdMain`
- `POST /SupCategorys/GetSupCategoryById`
- `POST /SupCategorys/GetAllShowSupCategories`
- `POST /SupCategorys/GetAllSupCategories`

### Items

- `POST /Items/ManageItem`
- `POST /Items/GetItemById`
- `POST /Items/GetAllShowItemsBySupCatId`
- `POST /Items/GetAllNotShowItemsBySupCatId`
- `POST /Items/GetAllItemsToSup`
- `POST /Items/AddImgToItem`
- `POST /Items/DeleteImg`
- `POST /Items/GetAllItemsShowByMainCategory`
- `POST /Items/GetAllItemIsMoreSales`
- `POST /Items/GetAllItemByName`
- `POST /Items/GetAllFiterItems`

### Orders

- `POST /Orders/ManageOrder`
- `POST /Orders/GetOrderById`
- `POST /Orders/GetAllOrdersByStatus`
- `POST /Orders/GetAllOrdersByUserId`
- `POST /Orders/GetAllOrdersByCityOrder`

### Cities

- `POST /Cities/ManageCity`
- `POST /Cities/GetAllCities`
- `GET /Cities/GetCityById`
- `DELETE /Cities/DeleteCity`

### Comments

- `POST /api/Comments/ManageComment`
- `POST /api/Comments/GetAllComments`
- `POST /api/Comments/GetAllCommentsToUser`
- `POST /api/Comments/GetAllCommentsToItem`
- `DELETE /api/Comments/DeleteComment`

### Notifications

- `POST /api/Notifications/EditNotification`
- `POST /api/Notifications/GetNotifications`
- `DELETE /api/Notifications/DeleteNotification`
- `POST /api/Notifications/GetNotificationById`

### OnlineAds

- `POST /OnlineAds/ManageAds`
- `POST /OnlineAds/GetAllAds`
- `GET /OnlineAds/GetAdsById`

### DiscoundCodes

- `POST /DiscoundCodes/ManageDicoundCode`
- `POST /DiscoundCodes/GetByDiscoundCode`
- `POST /DiscoundCodes/GetAllOrdersHasDiscoundCode`
- `POST /DiscoundCodes/GetAllOrdersByDiscoundCode`
- `POST /DiscoundCodes/GetAllDiscoundCode`

### Settings

- `POST /Settings/EditSetting`
- `POST /Settings/CheckSetting`

### Other old-backend endpoints

- `GET /Homes/Stats`
- `GET /Role/GetAllRoles`
- `GET /Role/GetRoleById`
- `POST /Complaints/AddComplaint`
- `POST /Complaints/GetAllComplaints`
- `DELETE /Complaints/Delete`

## Laravel migration priority

To make the current mobile app work first, build these groups in order:

1. Auth/users/settings: login, register, check user, profile, password, settings.
2. Catalog: main categories, subcategories, items, item details, search, images.
3. Cart/order: cities, discount code, manage order, user order history.
4. Social/user extras: comments and notifications.

Keep the route names and response JSON shape compatible at first. After the app works, routes can be cleaned up with a Flutter-side migration.
