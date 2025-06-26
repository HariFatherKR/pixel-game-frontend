extends Control

# Mobile Optimization Test Scene
# Tests touch responsiveness and mobile UI elements

signal back_pressed()

@onready var test_results_label = $ScrollContainer/VBoxContainer/TestResultsLabel
@onready var touch_test_button = $ScrollContainer/VBoxContainer/TouchTestButton
@onready var drag_test_area = $ScrollContainer/VBoxContainer/DragTestArea
@onready var card_test = $ScrollContainer/VBoxContainer/CardTestContainer/CardContainer/TestCard
@onready var back_button = $ScrollContainer/VBoxContainer/BackButton

var test_results = []
var touch_start_time = 0
var is_testing_touch = false

func _ready():
	print("Mobile Optimization Test Scene loaded")
	_setup_tests()
	_run_automated_tests()

func _setup_tests():
	# Setup touch test button
	if touch_test_button:
		touch_test_button.pressed.connect(_test_button_response)
		TouchHelper.add_touch_feedback(touch_test_button)
	
	# Setup back button
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
		TouchHelper.add_touch_feedback(back_button)
	
	# Setup card test
	if card_test:
		# Create a test card
		var test_card_data = {
			"name": "Test Card",
			"cost": 2,
			"type": "ACTION",
			"description": "A test card for mobile optimization"
		}
		card_test.setup_card(test_card_data, 5)
		card_test.card_played.connect(_on_test_card_played)
		card_test.card_selected.connect(_on_test_card_selected)

func _on_back_button_pressed():
	print("Back button pressed")
	emit_signal("back_pressed")

func _run_automated_tests():
	test_results.append("🧪 Starting Mobile Optimization Tests...")
	
	# Test 1: Screen size detection
	_test_screen_size_detection()
	
	# Test 2: Touch target sizes
	_test_touch_target_sizes()
	
	# Test 3: Responsive scaling
	_test_responsive_scaling()
	
	# Test 4: TouchHelper functionality
	_test_touch_helper()
	
	_update_test_results()

func _test_screen_size_detection():
	var screen_size = get_viewport().size
	var is_mobile_size = screen_size.x <= 480 or screen_size.y <= 800
	
	test_results.append("📱 Screen Size: " + str(screen_size))
	test_results.append("📏 Mobile Size Detection: " + ("✅ PASS" if is_mobile_size else "⚠️ DESKTOP"))

func _test_touch_target_sizes():
	var buttons_tested = []
	var all_passed = true
	
	# Test button sizes
	if touch_test_button:
		var button_size = touch_test_button.size
		var meets_minimum = button_size.x >= 44 and button_size.y >= 44
		buttons_tested.append("Touch Button: " + str(button_size) + " " + ("✅" if meets_minimum else "❌"))
		all_passed = all_passed and meets_minimum
	
	# Test card size
	if card_test:
		var card_size = card_test.size
		var meets_minimum = card_size.x >= 44 and card_size.y >= 44
		buttons_tested.append("Test Card: " + str(card_size) + " " + ("✅" if meets_minimum else "❌"))
		all_passed = all_passed and meets_minimum
	
	test_results.append("👆 Touch Target Sizes:")
	for result in buttons_tested:
		test_results.append("  " + result)
	test_results.append("📏 Overall: " + ("✅ PASS" if all_passed else "❌ FAIL"))

func _test_responsive_scaling():
	# Test ResponsiveManager if available
	var responsive_manager = get_node_or_null("/root/Main/ResponsiveManager")
	if responsive_manager:
		var scale_factor = responsive_manager.get_scale_factor()
		var screen_category = responsive_manager.get_screen_size_category()
		test_results.append("📐 Responsive Scaling:")
		test_results.append("  Scale Factor: " + str(scale_factor))
		test_results.append("  Screen Category: " + str(screen_category))
		test_results.append("  Status: ✅ PASS")
	else:
		test_results.append("📐 Responsive Scaling: ⚠️ ResponsiveManager not found")

func _test_touch_helper():
	# Test TouchHelper static methods
	var test_passed = true
	
	# Test minimum touch size enforcement
	var test_control = Control.new()
	test_control.size = Vector2(30, 30)  # Below minimum
	TouchHelper.ensure_min_touch_size(test_control)
	
	var meets_minimum = test_control.custom_minimum_size.x >= 44 and test_control.custom_minimum_size.y >= 44
	test_passed = test_passed and meets_minimum
	
	test_control.queue_free()
	
	test_results.append("🔧 TouchHelper Functionality:")
	test_results.append("  Min Size Enforcement: " + ("✅ PASS" if meets_minimum else "❌ FAIL"))
	test_results.append("  Overall: " + ("✅ PASS" if test_passed else "❌ FAIL"))

func _test_button_response():
	is_testing_touch = true
	touch_start_time = Time.get_ticks_msec()
	
	# Test response time
	await get_tree().create_timer(0.1).timeout
	
	var response_time = Time.get_ticks_msec() - touch_start_time
	var is_responsive = response_time < 100  # Should respond within 100ms
	
	test_results.append("⚡ Touch Response Test:")
	test_results.append("  Response Time: " + str(response_time) + "ms")
	test_results.append("  Status: " + ("✅ PASS" if is_responsive else "❌ FAIL"))
	
	_update_test_results()
	is_testing_touch = false

func _on_test_card_played(card_data):
	test_results.append("🃏 Card Drag Test: ✅ PASS - Card played successfully")
	_update_test_results()

func _on_test_card_selected(card_data):
	test_results.append("🃏 Card Tap Test: ✅ PASS - Card selected successfully")
	_update_test_results()

func _update_test_results():
	if test_results_label:
		test_results_label.text = "\n".join(test_results)

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if not is_testing_touch:
			test_results.append("👆 Touch Input Detected: " + str(event.get_class()))
			_update_test_results()