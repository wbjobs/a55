class_name ConditionRandomChance
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var chance: float = float(get_property("chance", 0.5))
	chance = clampf(chance, 0.0, 1.0)
	return randf() < chance
