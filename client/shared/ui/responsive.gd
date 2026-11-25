class_name Responsive
extends RefCounted

const COMPACT_MAX: float = 480.0
const MEDIUM_MAX: float = 720.0

static func columns_for(width: float) -> int:
	if width < COMPACT_MAX:
		return 1
	if width < MEDIUM_MAX:
		return 2
	return 3

static func is_tablet(width: float) -> bool:
	return width >= MEDIUM_MAX
