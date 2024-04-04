extends Node

signal unlock_new_skin

var google_payment = null
var new_skin_sku = "new_player_skin"
var new_skin_token = ""

var apple_payment = null
var apple_product_id = "player_new_skin"

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		google_payment = Engine.get_singleton("GodotGooglePlayBilling")
		MyUtility.add_log_message("Android IAP support enabled")
		
		google_payment.connected.connect(_on_connected)
		google_payment.connect_error.connect(_on_connect_error)
		google_payment.disconnected.connect(_on_disconnected)
		
		google_payment.sku_details_query_completed.connect(_on_sku_details_query_completed)
		google_payment.sku_details_query_error.connect(_on_sku_details_query_error)
		
		google_payment.purchases_updated.connect(_on_purchases_updated)
		google_payment.purchase_error.connect(_on_purchase_error)
		
		google_payment.purchase_acknowledged.connect(_on_purchase_acknowledged)
		google_payment.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error)
		
		google_payment.query_purchases_response.connect(_on_query_purchases_response)
		
		google_payment.purchase_consumed.connect(_on_purchase_consumed)
		google_payment.purchase_consumption_error.connect(_on_purchase_consumption_error)
		
		google_payment.startConnection()
	else:
		MyUtility.add_log_message("Android IAP not available")
		
	if Engine.has_singleton("InAppStore"):
		apple_payment = Engine.get_singleton("InAppStore")
		MyUtility.add_log_message("iOS IAP support enabled")
		
		var result = apple_payment.request_product_info({"product_ids": [apple_product_id]})
		if result == OK:
			MyUtility.add_log_message("Successfully started product info request")
			apple_payment.set_auto_finish_transaction(true)
			
			var timer = Timer.new()
			timer.wait_time = 1
			timer.timeout.connect(check_events)
			add_child(timer)
			timer.start()
	else:
		MyUtility.add_log_message("iOS IAP not available")

func purchase_skin():
	if google_payment:
		var response = google_payment.purchase(new_skin_sku)
		if response.status != OK:
			MyUtility.add_log_msg("Error purchasing skin")
	elif apple_payment:
		var result = apple_payment.purchase({"product_id": apple_product_id})
		if result == OK:
			MyUtility.add_log_message("Purchase result is OK!")
		else:
			MyUtility.add_log_message("Purchase failed!")
		
func reset_purchases():
	if google_payment:
		if !new_skin_token.is_empty():
			google_payment.consumePurchase(new_skin_token)
	if apple_payment:
		pass
	
func check_events():
	while apple_payment.get_pending_event_count() > 0:
		var event = apple_payment.pop_pending_event()
		if event.result == "ok":
			match event.type:
				"product_info":
					MyUtility.add_log_msg(str(event))
					restore_purchases()
				"purchase":
					if event.product_id == apple_product_id:
						unlock_new_skin.emit()
				"restore":
					if event.product_id == apple_product_id:
						unlock_new_skin.emit()
			
func _on_connected():
	MyUtility.add_log_message("Connected")
	google_payment.querySkuDetails([new_skin_sku], "inapp")
	
func _on_connect_error(response_id, debug_msg):
	MyUtility.add_log_message("Connect error, response id: " + 
	str(response_id) + " debug msg: " + debug_msg)
	
func _on_disconnected():
	MyUtility.add_log_message("Disconnected")

func _on_sku_details_query_completed(skus):
	MyUtility.add_log_message("SKu details query completed")
	for sku in skus:
		MyUtility.add_log_message("Sku:")
		MyUtility.add_log_message(str(sku))
		
	google_payment.queryPurchases("inapp")
	
func _on_sku_details_query_error(response_id, error_message, skus):	
	MyUtility.add_log_message("Connect error, response id: " + 
	str(response_id) + ", error msg: " + error_message + ", skus: " + str(skus))
	
func _on_purchases_updated(purchases):
	if purchases.size() > 0:
		var purchase = purchases[0]
		var purchase_sku = purchase["skus"][0]
		
		if purchase_sku == new_skin_sku:
			new_skin_token = purchase.purchase_token
			google_payment.acknowledgePurchase(new_skin_token)

func _on_purchase_error(response_id, error_message):
	MyUtility.add_log_message("Purchase error, response id: " + 
	str(response_id) + " error msg: " + error_message)

func _on_purchase_acknowledged(purchase_token):
	
	if !new_skin_token.is_empty():
		if new_skin_token == purchase_token:
			unlock_new_skin.emit()

func _on_purchase_acknowledgement_error(response_id, error_message, purchase_token):
	MyUtility.add_log_message("Purchase acknowledgement error, response id: " + 
	str(response_id) + " error msg: " + error_message  + ", token: " + str(purchase_token))

func _on_query_purchases_response(query_result):
	if query_result.status == OK:
		var purchases = query_result.purchases
		var purchase = purchases[0]
		var purchase_sku = purchase["skus"][0]
		if new_skin_sku == purchase_sku:
			new_skin_token = purchase.purchase_token
			if !purchase.is_acknowledged:
				google_payment.acknowledgePurchase(purchase.purchase_token)
			else:
				unlock_new_skin.emit()

func _on_purchase_consumed(purchase_token):
	MyUtility.add_log_message("Purchase consumed successfully")

func _on_purchase_consumption_error(response_id, error_message, purchase_token):
	MyUtility.add_log_message("Purchase consumption error, response id: " + 
	str(response_id) + " error msg: " + error_message  + ", token: " + str(purchase_token))

func restore_purchases():
	if apple_payment:
		var result = apple_payment.restore_purchases()
		if result == OK:
			MyUtility.add_log_msg("Restore purchases call is successfull")
		else:
			MyUtility.add_log_msg("Restore purchases call failed")
	elif google_payment:
		google_payment.queryPurchases("inapp")
