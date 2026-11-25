class_name CosmeticTiers
extends RefCounted

# Acquisition tiers are catalog metadata. They do not grant ownership,
# rewards, or any price authority; the server owns those decisions.

const FREE: StringName = &"free"
const PAID: StringName = &"paid"
const AD_REWARD: StringName = &"ad_reward"
