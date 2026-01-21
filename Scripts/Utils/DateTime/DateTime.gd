class DateTime:
	var year: int
	var month: int
	var day: int

	var hour: int
	var minute: int
	var second: int

	var milliSecond: float


	func reset() -> DateTime:
		setYear(0)
		setMonth(0)
		setDay(0)
		setHour(0)
		setMinute(0)
		setSecond(0)
		setMilliSecond(0.0)
		return self


	func getYear() -> int:
		return year

	func setYear(newYear: int) -> void:
		year = newYear
		return

	func getMonth() -> int:
		return month

	func setMonth(newMonth: int) -> void:
		month = newMonth
		return

	func getDay() -> int:
		return day

	func setDay(newDay: int) -> void:
		day = newDay
		return

	func getHour() -> int:
		return hour

	func setHour(newHour: int) -> void:
		hour = newHour
		return

	func getMinute() -> int:
		return minute

	func setMinute(newMinute: int) -> void:
		minute = newMinute
		return

	func getSecond() -> int:
		return second

	func setSecond(newSecond: int) -> void:
		second = newSecond
		return

	func getMilliSecond() -> float:
		return milliSecond

	func setMilliSecond(newMilliSecond: float) -> void:
		milliSecond = newMilliSecond
		return
