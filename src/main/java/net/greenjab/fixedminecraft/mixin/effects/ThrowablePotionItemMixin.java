package net.greenjab.fixedminecraft.mixin.effects;

import net.minecraft.item.LingeringPotionItem;
import net.minecraft.item.ThrowablePotionItem;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.ModifyArg;

@Mixin(ThrowablePotionItem.class)
public class ThrowablePotionItemMixin {
    @ModifyArg(method = "use", at = @At(value = "INVOKE", target = "Lnet/minecraft/entity/projectile/ProjectileEntity;spawnWithVelocity(Lnet/minecraft/entity/projectile/ProjectileEntity$ProjectileCreator;Lnet/minecraft/server/world/ServerWorld;Lnet/minecraft/item/ItemStack;Lnet/minecraft/entity/LivingEntity;FFF)Lnet/minecraft/entity/projectile/ProjectileEntity;"), index = 5)
    private float longerLingeringThrows(float constant){
        ThrowablePotionItem TPI = (ThrowablePotionItem)(Object)this;
        if (TPI instanceof LingeringPotionItem) {
            return 0.85f;
        }
        return constant;
    }
}
