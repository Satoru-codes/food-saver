const EN = {
  pantry:"Shared pantry", subtitle:"Everything your household keeps, in one place.",
  signOut:"Sign out", addFood:"Add food", refresh:"Refresh",
  totalItems:"Food items", expiringSoon:"Expiring in 7 days", outOfStock:"Out of stock",
  search:"Search food items…", allCategories:"All categories", allLocations:"All locations",
  noItems:"Your pantry is empty", noItemsHint:"Add your first food item to get started.",
  addFirst:"Add your first item", addItem:"Add food item", editItem:"Edit food item",
  itemName:"Food name", category:"Category", quantity:"Available quantity", unit:"Unit",
  expiry:"Expiry date", location:"Storage location", noLocation:"No location assigned",
  notes:"Notes (optional)", saveItem:"Save item", cancel:"Cancel",
  addLocation:"Add storage location", locationName:"Location name", saveLocation:"Add location",
  edit:"Edit", archive:"Archive", restock:"Add stock", restockTitle:"Add stock",
  amountToAdd:"Quantity to add", addStock:"Add stock", activity:"Recent inventory activity",
  noActivity:"No inventory activity yet.", added:"Added", adjustment:"Adjusted",
  consumption:"Consumed", waste:"Waste", reversal:"Undo", expired:"Expired",
  expiring:"Expiring soon", archived:"Item archived.", itemSaved:"Food item saved.",
  locationSaved:"Storage location added.", stockAdded:"Stock added.",
  movementReversed:"Inventory activity undone.",
  confirmArchive:"Archive this item? Its history will be kept.",
  confirmUndo:"Undo this inventory activity?",
  permissionView:"You can view the shared pantry. An Admin can grant inventory-management permission.",
  locationHelp:"Locations are optional. Categories work independently of storage locations.",
  noResults:"No items match these filters.", roleOwner:"Owner", roleAdmin:"Admin",
  roleMember:"Member", close:"Close", loading:"Loading pantry…",
  errorLoad:"Could not load the pantry. Please refresh and try again.",
  quantityRequired:"Enter a valid quantity greater than or equal to zero.",
  stockRequired:"Enter a valid quantity greater than zero.", nameRequired:"Enter a food name.",
  categoryRequired:"Choose a category.", locationRequired:"Enter a location name.",
  itemNamePlaceholder:"e.g. Milk", locationPlaceholder:"e.g. Refrigerator",
  activityByYou:"You", activityByMember:"Household member",
  kg:"kg", g:"g", L:"L", ml:"ml", pcs:"pieces", pack:"packs", unit:"units"
};

const HI = {
  pantry:"साझा पैंट्री", subtitle:"आपके घर का सारा सामान, एक ही जगह।",
  signOut:"साइन आउट", addFood:"खाना जोड़ें", refresh:"रिफ्रेश",
  totalItems:"खाद्य वस्तुएँ", expiringSoon:"7 दिनों में समाप्त", outOfStock:"स्टॉक खत्म",
  search:"खाद्य वस्तुएँ खोजें…", allCategories:"सभी श्रेणियाँ", allLocations:"सभी स्थान",
  noItems:"आपकी पैंट्री खाली है", noItemsHint:"शुरू करने के लिए पहली खाद्य वस्तु जोड़ें।",
  addFirst:"पहली वस्तु जोड़ें", addItem:"खाद्य वस्तु जोड़ें", editItem:"खाद्य वस्तु बदलें",
  itemName:"खाद्य पदार्थ का नाम", category:"श्रेणी", quantity:"उपलब्ध मात्रा", unit:"इकाई",
  expiry:"समाप्ति तिथि", location:"रखने का स्थान", noLocation:"कोई स्थान नहीं चुना",
  notes:"टिप्पणी (वैकल्पिक)", saveItem:"वस्तु सेव करें", cancel:"रद्द करें",
  addLocation:"भंडारण स्थान जोड़ें", locationName:"स्थान का नाम", saveLocation:"स्थान जोड़ें",
  edit:"बदलें", archive:"आर्काइव", restock:"स्टॉक जोड़ें", restockTitle:"स्टॉक जोड़ें",
  amountToAdd:"जोड़ने की मात्रा", addStock:"स्टॉक जोड़ें", activity:"हाल की इन्वेंटरी गतिविधि",
  noActivity:"अभी कोई इन्वेंटरी गतिविधि नहीं है।", added:"जोड़ा", adjustment:"बदला",
  consumption:"इस्तेमाल", waste:"बर्बादी", reversal:"Undo", expired:"समाप्त",
  expiring:"जल्द समाप्त होगा", archived:"वस्तु आर्काइव कर दी गई।",
  itemSaved:"खाद्य वस्तु सेव हो गई।", locationSaved:"भंडारण स्थान जुड़ गया।",
  stockAdded:"स्टॉक जोड़ दिया गया।", movementReversed:"इन्वेंटरी गतिविधि वापस कर दी गई।",
  confirmArchive:"क्या इस वस्तु को आर्काइव करना है? इसका इतिहास सुरक्षित रहेगा।",
  confirmUndo:"क्या इस इन्वेंटरी गतिविधि को वापस करना है?",
  permissionView:"आप साझा पैंट्री देख सकते हैं। Admin आपको इन्वेंटरी प्रबंधन की अनुमति दे सकता है।",
  locationHelp:"स्थान चुनना वैकल्पिक है। श्रेणियाँ भंडारण स्थान से अलग काम करती हैं।",
  noResults:"इन फ़िल्टर से कोई वस्तु नहीं मिली।", roleOwner:"Owner", roleAdmin:"Admin",
  roleMember:"Member", close:"बंद करें", loading:"पैंट्री लोड हो रही है…",
  errorLoad:"पैंट्री लोड नहीं हो सकी। रिफ्रेश करके फिर कोशिश करें।",
  quantityRequired:"शून्य या उससे अधिक सही मात्रा दर्ज करें।",
  stockRequired:"शून्य से अधिक सही मात्रा दर्ज करें।", nameRequired:"खाद्य पदार्थ का नाम लिखें।",
  categoryRequired:"श्रेणी चुनें।", locationRequired:"स्थान का नाम लिखें।",
  itemNamePlaceholder:"जैसे दूध", locationPlaceholder:"जैसे फ्रिज",
  activityByYou:"आप", activityByMember:"परिवार का सदस्य",
  kg:"किलो", g:"ग्राम", L:"लीटर", ml:"मिलीलीटर", pcs:"नग", pack:"पैक", unit:"इकाई"
};

const escapeHtml = function(value) {
  return String(value == null ? "" : value).replace(/[&<>"']/g, function(char) {
    return {"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[char];
  });
};

const UNIT_GROUPS = {g:["g","kg"], ml:["ml","L"], pcs:["pcs"], pack:["pack"], unit:["unit"]};

function toBaseQuantity(quantity, displayUnit) {
  return Number((quantity * (displayUnit === "kg" || displayUnit === "L" ? 1000 : 1)).toFixed(3));
}

function displayQuantity(quantityBase, baseUnit, displayUnit, language) {
  const divisor = displayUnit === "kg" || displayUnit === "L" ? 1000 : 1;
  const amount = new Intl.NumberFormat(language === "hi" ? "hi-IN" : "en-IN", {maximumFractionDigits:3}).format(quantityBase / divisor);
  return amount + " " + displayUnit;
}

function dateStatus(expiryDate, t) {
  if (!expiryDate) return "";
  const today = new Date();
  today.setHours(0,0,0,0);
  const expiry = new Date(expiryDate + "T00:00:00");
  const diff = Math.ceil((expiry - today) / 86400000);
  if (diff < 0) return '<span class="food-tag danger">' + escapeHtml(t("expired")) + '</span>';
  if (diff <= 7) return '<span class="food-tag warning">' + escapeHtml(t("expiring")) + '</span>';
  return "";
}

export function mountPantry(config) {
  const supabase = config.supabase;
  const container = config.container;
  const household = config.household;
  const membership = config.membership;
  const user = config.user;
  const onSignOut = config.onSignOut;
  let currentLanguage = config.language || "en";
  let items = [];
  let categories = [];
  let locations = [];
  let activities = [];
  let editingItem = null;
  let selectedStockItem = null;
  let activeCategory = "all";
  let activeLocation = "all";
  let searchTerm = "";
  let busy = false;
  let destroyed = false;
  const abortController = new AbortController();
  const canManage = membership.role === "owner" || membership.can_manage_inventory === true;
  const roleKey = membership.role === "owner" ? "roleOwner" : membership.role === "admin" ? "roleAdmin" : "roleMember";
  const t = function(key) { return (currentLanguage === "hi" ? HI[key] : EN[key]) || EN[key] || key; };

  container.innerHTML = [
    '<div class="pantry-app">',
    '<section class="pantry-heading"><div><p class="eyebrow">' + escapeHtml(household.name) + '</p><h1>' + escapeHtml(t("pantry")) + '</h1><p class="pantry-subtitle">' + escapeHtml(t("subtitle")) + '</p></div>',
    '<div class="pantry-heading-actions"><span class="role-chip" id="pantry-role"></span><button class="quiet-button" type="button" data-action="refresh">' + escapeHtml(t("refresh")) + '</button><button class="quiet-button" type="button" data-action="signout">' + escapeHtml(t("signOut")) + '</button>',
    canManage ? '<button class="pantry-primary" type="button" data-action="new-item">＋ ' + escapeHtml(t("addFood")) + '</button>' : '',
    '</div></section>',
    canManage ? '' : '<p class="permission-note">' + escapeHtml(t("permissionView")) + '</p>',
    '<div class="pantry-stat-grid" id="pantry-stats"></div>',
    '<section class="pantry-panel"><div class="pantry-toolbar"><input class="pantry-search" id="pantry-search" type="search" placeholder="' + escapeHtml(t("search")) + '" aria-label="' + escapeHtml(t("search")) + '" />',
    '<select id="pantry-category-filter" aria-label="' + escapeHtml(t("category")) + '"></select><select id="pantry-location-filter" aria-label="' + escapeHtml(t("location")) + '"></select></div>',
    '<div class="pantry-section-title"><h2>' + escapeHtml(t("totalItems")) + '</h2><span id="pantry-item-count" class="muted-count"></span></div>',
    '<div id="pantry-item-form-wrap" class="pantry-form-wrap" hidden><form id="pantry-item-form" class="pantry-form">',
    '<div class="form-heading"><h3 id="pantry-form-title"></h3><button type="button" class="icon-button" data-action="close-item-form" aria-label="' + escapeHtml(t("close")) + '">×</button></div>',
    '<div class="pantry-form-grid">',
    '<label>' + escapeHtml(t("itemName")) + '<input class="field-input" name="name" id="food-name" maxlength="100" required /></label>',
    '<label>' + escapeHtml(t("category")) + '<select class="field-input" name="category_key" id="food-category" required></select></label>',
    '<label id="food-quantity-wrap">' + escapeHtml(t("quantity")) + '<div class="quantity-fields"><input class="field-input" type="number" name="quantity" id="food-quantity" min="0" step="0.001" value="0" required /><select class="field-input unit-select" name="display_unit" id="food-unit"></select></div><small id="quantity-help"></small></label>',
    '<label>' + escapeHtml(t("expiry")) + '<input class="field-input" type="date" name="expiry_date" id="food-expiry" /></label>',
    '<label>' + escapeHtml(t("location")) + '<select class="field-input" name="storage_location_id" id="food-location"></select></label>',
    '<label>' + escapeHtml(t("notes")) + '<input class="field-input" name="notes" id="food-notes" maxlength="500" /></label>',
    '</div><p class="inline-message" id="pantry-form-message" role="status" aria-live="polite" hidden></p>',
    '<div class="form-actions"><button type="button" class="quiet-button" data-action="close-item-form">' + escapeHtml(t("cancel")) + '</button><button type="submit" class="pantry-primary">' + escapeHtml(t("saveItem")) + '</button></div>',
    '</form></div>',
    '<div id="pantry-items" class="pantry-item-grid"><p class="loading-note">' + escapeHtml(t("loading")) + '</p></div>',
    '<div class="location-tools"><details id="location-details"><summary>' + escapeHtml(t("addLocation")) + '</summary><form id="location-form" class="location-form">',
    '<input class="field-input" name="name" maxlength="60" required placeholder="' + escapeHtml(t("locationPlaceholder")) + '" aria-label="' + escapeHtml(t("locationName")) + '" />',
    '<button class="quiet-button" type="submit">' + escapeHtml(t("saveLocation")) + '</button></form><small>' + escapeHtml(t("locationHelp")) + '</small></details></div></section>',
    '<section class="pantry-panel activity-panel"><div class="pantry-section-title"><h2>' + escapeHtml(t("activity")) + '</h2><span class="muted-count">Last 8</span></div><div id="pantry-activity" class="activity-list"><p class="empty-hint">' + escapeHtml(t("loading")) + '</p></div></section>',
    '<dialog id="stock-dialog" class="stock-dialog"><form method="dialog" class="dialog-close-row"><button class="icon-button" aria-label="' + escapeHtml(t("close")) + '">×</button></form>',
    '<form id="stock-form" class="stock-form"><h3>' + escapeHtml(t("restockTitle")) + '</h3><p id="stock-item-label" class="form-intro"></p>',
    '<label>' + escapeHtml(t("amountToAdd")) + '<div class="quantity-fields"><input class="field-input" name="quantity" id="stock-quantity" type="number" min="0.001" step="0.001" required /><span id="stock-unit" class="unit-label"></span></div></label>',
    '<p class="inline-message" id="stock-message" role="status" aria-live="polite" hidden></p><div class="form-actions"><button type="button" class="quiet-button" data-action="close-stock">' + escapeHtml(t("cancel")) + '</button><button type="submit" class="pantry-primary">' + escapeHtml(t("addStock")) + '</button></div></form></dialog>',
    '<div id="pantry-toast" class="pantry-toast" role="status" aria-live="polite" hidden></div></div>'
  ].join("");

  const $ = function(selector) { return container.querySelector(selector); };

  function toast(message, type) {
    const node = $("#pantry-toast");
    node.textContent = message;
    node.className = "pantry-toast " + (type || "success");
    node.hidden = false;
    window.clearTimeout(toast.timer);
    toast.timer = window.setTimeout(function() { node.hidden = true; }, 3200);
  }

  function setFormMessage(message) {
    const node = $("#pantry-form-message");
    node.textContent = message;
    node.className = "inline-message error";
    node.hidden = false;
  }

  function renderFilters() {
    $("#pantry-category-filter").innerHTML = '<option value="all">' + escapeHtml(t("allCategories")) + '</option>' +
      categories.map(function(cat) { return '<option value="' + escapeHtml(cat.key) + '">' + escapeHtml(currentLanguage === "hi" ? cat.label_hi : cat.label_en) + '</option>'; }).join("");
    $("#pantry-location-filter").innerHTML = '<option value="all">' + escapeHtml(t("allLocations")) + '</option>' +
      locations.map(function(loc) { return '<option value="' + escapeHtml(loc.id) + '">' + escapeHtml(loc.name) + '</option>'; }).join("");
    $("#pantry-category-filter").value = activeCategory;
    $("#pantry-location-filter").value = activeLocation;
  }

  function renderFormOptions() {
    $("#food-category").innerHTML = categories.map(function(cat) {
      return '<option value="' + escapeHtml(cat.key) + '">' + escapeHtml(currentLanguage === "hi" ? cat.label_hi : cat.label_en) + '</option>';
    }).join("");
    $("#food-location").innerHTML = '<option value="">' + escapeHtml(t("noLocation")) + '</option>' +
      locations.map(function(loc) { return '<option value="' + escapeHtml(loc.id) + '">' + escapeHtml(loc.name) + '</option>'; }).join("");
  }

  function renderStats() {
    const today = new Date();
    today.setHours(0,0,0,0);
    const inSeven = new Date(today);
    inSeven.setDate(inSeven.getDate() + 7);
    const expiring = items.filter(function(item) {
      if (!item.expiry_date) return false;
      const date = new Date(item.expiry_date + "T00:00:00");
      return date >= today && date <= inSeven;
    }).length;
    const out = items.filter(function(item) { return Number(item.quantity_base) === 0; }).length;
    $("#pantry-stats").innerHTML = [
      '<article class="pantry-stat"><span>' + escapeHtml(t("totalItems")) + '</span><strong>' + items.length + '</strong></article>',
      '<article class="pantry-stat"><span>' + escapeHtml(t("expiringSoon")) + '</span><strong>' + expiring + '</strong></article>',
      '<article class="pantry-stat"><span>' + escapeHtml(t("outOfStock")) + '</span><strong>' + out + '</strong></article>'
    ].join("");
  }

  function renderItems() {
    const query = searchTerm.toLocaleLowerCase();
    const filtered = items.filter(function(item) {
      return (!query || item.name.toLocaleLowerCase().includes(query)) &&
        (activeCategory === "all" || item.category_key === activeCategory) &&
        (activeLocation === "all" || item.storage_location_id === activeLocation);
    });
    $("#pantry-item-count").textContent = filtered.length + " / " + items.length;
    if (!filtered.length) {
      const empty = items.length === 0;
      $("#pantry-items").innerHTML = '<div class="pantry-empty"><div class="empty-icon">🥬</div><h3>' +
        escapeHtml(t(empty ? "noItems" : "noResults")) + '</h3><p>' +
        escapeHtml(t(empty ? "noItemsHint" : "noResults")) + '</p>' +
        (empty && canManage ? '<button type="button" class="pantry-primary" data-action="new-item">' + escapeHtml(t("addFirst")) + '</button>' : '') +
        '</div>';
      return;
    }
    $("#pantry-items").innerHTML = filtered.map(function(item) {
      const cat = categories.find(function(c) { return c.key === item.category_key; });
      const loc = locations.find(function(l) { return l.id === item.storage_location_id; });
      const amount = displayQuantity(Number(item.quantity_base), item.base_unit, item.display_unit, currentLanguage);
      const expiry = item.expiry_date ? new Date(item.expiry_date + "T00:00:00").toLocaleDateString(currentLanguage === "hi" ? "hi-IN" : "en-IN", {day:"numeric",month:"short",year:"numeric"}) : "";
      const actions = canManage ? '<div class="food-actions"><button class="mini-button" type="button" data-action="edit-item" data-id="' + escapeHtml(item.id) + '">' + escapeHtml(t("edit")) + '</button><button class="mini-button" type="button" data-action="restock-item" data-id="' + escapeHtml(item.id) + '">' + escapeHtml(t("restock")) + '</button><button class="mini-button danger-button" type="button" data-action="archive-item" data-id="' + escapeHtml(item.id) + '">' + escapeHtml(t("archive")) + '</button></div>' : "";
      return '<article class="food-card"><div class="food-card-top"><span class="food-category-label">' +
        escapeHtml(cat ? (currentLanguage === "hi" ? cat.label_hi : cat.label_en) : item.category_key) + '</span>' +
        dateStatus(item.expiry_date, t) + '</div><h3>' + escapeHtml(item.name) + '</h3><div class="food-quantity">' +
        escapeHtml(amount) + '</div><div class="food-meta"><span>⌖ ' + escapeHtml(loc ? loc.name : t("noLocation")) +
        '</span>' + (expiry ? '<span>◷ ' + escapeHtml(expiry) + '</span>' : '') + '</div>' +
        (item.notes ? '<p class="food-notes">' + escapeHtml(item.notes) + '</p>' : '') + actions + '</article>';
    }).join("");
  }

  function movementLabel(type) {
    const names = {addition:"added",adjustment:"adjustment",consumption:"consumption",waste:"waste",reversal:"reversal"};
    return t(names[type] || "adjustment");
  }

  function renderActivity() {
    if (!activities.length) {
      $("#pantry-activity").innerHTML = '<p class="empty-hint">' + escapeHtml(t("noActivity")) + '</p>';
      return;
    }
    $("#pantry-activity").innerHTML = activities.map(function(activity) {
      const item = items.find(function(entry) { return entry.id === activity.pantry_item_id; });
      const amount = displayQuantity(Math.abs(Number(activity.quantity_delta)), activity.base_unit, activity.base_unit, currentLanguage);
      const actor = activity.actor_user_id === user.id ? t("activityByYou") : t("activityByMember");
      const date = new Date(activity.created_at).toLocaleString(currentLanguage === "hi" ? "hi-IN" : "en-IN", {day:"numeric",month:"short",hour:"numeric",minute:"2-digit"});
      const canUndo = activity.movement_type !== "reversal" && (activity.actor_user_id === user.id || canManage);
      return '<div class="activity-row"><div class="activity-dot ' + escapeHtml(activity.movement_type) + '"></div><div class="activity-content"><strong>' +
        escapeHtml(item ? item.name : "Food item") + '</strong><span>' + escapeHtml(movementLabel(activity.movement_type)) + ' · ' +
        escapeHtml(amount) + ' · ' + escapeHtml(actor) + '</span><small>' + escapeHtml(date) + '</small></div>' +
        (canUndo ? '<button type="button" class="mini-button" data-action="undo-movement" data-id="' + escapeHtml(activity.id) + '">' + escapeHtml(t("reversal")) + '</button>' : '') +
        '</div>';
    }).join("");
  }

  function renderAll() {
    $("#pantry-role").textContent = t(roleKey);
    renderFilters();
    renderFormOptions();
    renderStats();
    renderItems();
    renderActivity();
    $("#location-details").hidden = !canManage;
  }

  async function loadData() {
    if (destroyed) return;
    $("#pantry-items").innerHTML = '<p class="loading-note">' + escapeHtml(t("loading")) + '</p>';
    const results = await Promise.all([
      supabase.from("food_categories").select("key,label_en,label_hi,sort_order").order("sort_order"),
      supabase.from("storage_locations").select("id,name,sort_order").eq("household_id",household.id).eq("is_active",true).order("sort_order"),
      supabase.from("pantry_items").select("id,household_id,name,category_key,storage_location_id,quantity_base,base_unit,display_unit,expiry_date,alert_days_before,notes,created_at,archived_at").eq("household_id",household.id).is("archived_at",null).order("name"),
      supabase.from("inventory_movements").select("id,pantry_item_id,movement_type,quantity_delta,base_unit,actor_user_id,created_at").eq("household_id",household.id).order("created_at",{ascending:false}).limit(8)
    ]);
    const error = results.map(function(result) { return result.error; }).find(Boolean);
    if (error) throw error;
    categories = results[0].data || [];
    locations = results[1].data || [];
    items = results[2].data || [];
    activities = results[3].data || [];
    renderAll();
  }

  function renderUnitOptions(baseUnit, selected) {
    const options = ["g","kg","ml","L","pcs","pack","unit"];
    $("#food-unit").innerHTML = options.map(function(unit) {
      return '<option value="' + unit + '">' + escapeHtml(t(unit)) + '</option>';
    }).join("");
    $("#food-unit").value = selected;
    $("#food-unit").disabled = Boolean(editingItem);
  }

  function openItemForm(item) {
    if (!canManage) return;
    editingItem = item || null;
    $("#pantry-item-form-wrap").hidden = false;
    $("#pantry-form-title").textContent = t(editingItem ? "editItem" : "addItem");
    $("#food-name").value = editingItem ? editingItem.name : "";
    $("#food-category").value = editingItem ? editingItem.category_key : (categories[0] ? categories[0].key : "");
    $("#food-expiry").value = editingItem ? editingItem.expiry_date || "" : "";
    $("#food-location").value = editingItem ? editingItem.storage_location_id || "" : "";
    $("#food-notes").value = editingItem ? editingItem.notes || "" : "";
    $("#food-quantity-wrap").hidden = Boolean(editingItem);
    $("#food-quantity").value = "0";
    $("#quantity-help").textContent = editingItem ? "" : "Initial stock is recorded automatically in inventory history.";
    renderUnitOptions(editingItem ? editingItem.base_unit : "g", editingItem ? editingItem.display_unit : "kg");
    $("#pantry-form-message").hidden = true;
    $("#food-name").focus();
    $("#pantry-item-form-wrap").scrollIntoView({behavior:"smooth",block:"nearest"});
  }

  function openStockDialog(item) {
    selectedStockItem = item;
    $("#stock-item-label").textContent = item.name + " · " + t("amountToAdd");
    $("#stock-unit").textContent = t(item.display_unit);
    $("#stock-quantity").value = "";
    $("#stock-message").hidden = true;
    $("#stock-dialog").showModal();
    $("#stock-quantity").focus();
  }

  async function saveItem(event) {
    event.preventDefault();
    if (!canManage || busy) return;
    const form = event.currentTarget;
    const values = new FormData(form);
    const name = String(values.get("name") || "").trim();
    const categoryKey = String(values.get("category_key") || "");
    const expiry = String(values.get("expiry_date") || "") || null;
    const locationId = String(values.get("storage_location_id") || "") || null;
    const notes = String(values.get("notes") || "").trim() || null;
    if (!name) return setFormMessage(t("nameRequired"));
    if (!categoryKey) return setFormMessage(t("categoryRequired"));
    busy = true;
    const submit = form.querySelector('[type="submit"]');
    submit.disabled = true;
    try {
      let result;
      if (editingItem) {
        result = await supabase.from("pantry_items").update({name:name,category_key:categoryKey,storage_location_id:locationId,expiry_date:expiry,notes:notes}).eq("id",editingItem.id).eq("household_id",household.id);
      } else {
        const quantity = Number(values.get("quantity"));
        const displayUnit = String(values.get("display_unit") || "g");
        if (!Number.isFinite(quantity) || quantity < 0) throw new Error(t("quantityRequired"));
        const baseUnit = displayUnit === "kg" ? "g" : displayUnit === "L" ? "ml" : displayUnit;
        result = await supabase.from("pantry_items").insert({
          household_id:household.id,name:name,category_key:categoryKey,storage_location_id:locationId,
          quantity_base:toBaseQuantity(quantity,displayUnit),base_unit:baseUnit,display_unit:displayUnit,
          expiry_date:expiry,notes:notes
        });
      }
      if (result.error) throw result.error;
      $("#pantry-item-form-wrap").hidden = true;
      editingItem = null;
      toast(t("itemSaved"));
      await loadData();
    } catch (error) {
      setFormMessage(error.message || t("errorLoad"));
    } finally {
      busy = false;
      submit.disabled = false;
    }
  }

  async function saveLocation(event) {
    event.preventDefault();
    if (!canManage || busy) return;
    const form = event.currentTarget;
    const name = String(new FormData(form).get("name") || "").trim();
    if (!name) return toast(t("locationRequired"),"error");
    busy = true;
    const button = form.querySelector('[type="submit"]');
    button.disabled = true;
    try {
      const result = await supabase.from("storage_locations").insert({household_id:household.id,name:name,sort_order:locations.length});
      if (result.error) throw result.error;
      form.reset();
      toast(t("locationSaved"));
      await loadData();
      $("#location-details").open = false;
    } catch (error) {
      toast(error.message || t("errorLoad"),"error");
    } finally {
      busy = false;
      button.disabled = false;
    }
  }

  async function saveStock(event) {
    event.preventDefault();
    if (!selectedStockItem || busy) return;
    const quantity = Number(new FormData(event.currentTarget).get("quantity"));
    if (!Number.isFinite(quantity) || quantity <= 0) {
      $("#stock-message").textContent = t("stockRequired");
      $("#stock-message").hidden = false;
      return;
    }
    busy = true;
    const button = event.currentTarget.querySelector('[type="submit"]');
    button.disabled = true;
    try {
      const result = await supabase.rpc("add_inventory_stock",{p_pantry_item_id:selectedStockItem.id,p_quantity_base:toBaseQuantity(quantity,selectedStockItem.display_unit)});
      if (result.error) throw result.error;
      $("#stock-dialog").close();
      toast(t("stockAdded"));
      await loadData();
    } catch (error) {
      $("#stock-message").textContent = error.message || t("errorLoad");
      $("#stock-message").hidden = false;
    } finally {
      busy = false;
      button.disabled = false;
    }
  }

  async function archiveItem(id) {
    if (!canManage || busy || !window.confirm(t("confirmArchive"))) return;
    busy = true;
    try {
      const result = await supabase.from("pantry_items").update({archived_at:new Date().toISOString()}).eq("id",id).eq("household_id",household.id);
      if (result.error) throw result.error;
      toast(t("archived"));
      await loadData();
    } catch (error) {
      toast(error.message || t("errorLoad"),"error");
    } finally {
      busy = false;
    }
  }

  async function undoMovement(id) {
    if (busy || !window.confirm(t("confirmUndo"))) return;
    busy = true;
    try {
      const result = await supabase.rpc("reverse_inventory_movement",{p_movement_id:id});
      if (result.error) throw result.error;
      toast(t("movementReversed"));
      await loadData();
    } catch (error) {
      toast(error.message || t("errorLoad"),"error");
    } finally {
      busy = false;
    }
  }

  container.addEventListener("click", async function(event) {
    const button = event.target.closest("[data-action]");
    if (!button) return;
    const action = button.dataset.action;
    const id = button.dataset.id;
    if (action === "new-item") openItemForm(null);
    if (action === "edit-item") openItemForm(items.find(function(item) { return item.id === id; }));
    if (action === "close-item-form") { $("#pantry-item-form-wrap").hidden = true; editingItem = null; }
    if (action === "restock-item") {
      const item = items.find(function(entry) { return entry.id === id; });
      if (item) openStockDialog(item);
    }
    if (action === "close-stock") $("#stock-dialog").close();
    if (action === "archive-item") await archiveItem(id);
    if (action === "undo-movement") await undoMovement(id);
    if (action === "refresh") {
      try { await loadData(); toast(t("refresh")); }
      catch (error) { toast(error.message || t("errorLoad"),"error"); }
    }
    if (action === "signout") await onSignOut();
  }, {signal:abortController.signal});

  $("#pantry-item-form").addEventListener("submit",saveItem,{signal:abortController.signal});
  $("#location-form").addEventListener("submit",saveLocation,{signal:abortController.signal});
  $("#stock-form").addEventListener("submit",saveStock,{signal:abortController.signal});
  $("#pantry-search").addEventListener("input",function(event) { searchTerm = event.target.value.trim(); renderItems(); },{signal:abortController.signal});
  $("#pantry-category-filter").addEventListener("change",function(event) { activeCategory = event.target.value; renderItems(); },{signal:abortController.signal});
  $("#pantry-location-filter").addEventListener("change",function(event) { activeLocation = event.target.value; renderItems(); },{signal:abortController.signal});
  $("#food-unit").addEventListener("change",function(event) {
    const unit = event.target.value;
    $("#quantity-help").textContent = "Stored accurately in " + (unit === "kg" ? "g" : unit === "L" ? "ml" : unit) + ".";
  },{signal:abortController.signal});

  const controller = {
    async reload() { await loadData(); },
    setLanguage(nextLanguage) {
      currentLanguage = nextLanguage === "hi" ? "hi" : "en";
      renderAll();
      $("#pantry-search").placeholder = t("search");
      $("#pantry-search").setAttribute("aria-label",t("search"));
    },
    destroy() {
      destroyed = true;
      abortController.abort();
      window.clearTimeout(toast.timer);
      container.replaceChildren();
    }
  };

  loadData().catch(function(error) {
    $("#pantry-items").innerHTML = '<div class="pantry-empty"><h3>' + escapeHtml(t("errorLoad")) + '</h3><p>' + escapeHtml(error.message || "") + '</p><button class="quiet-button" type="button" data-action="refresh">' + escapeHtml(t("refresh")) + '</button></div>';
  });
  return controller;
}
