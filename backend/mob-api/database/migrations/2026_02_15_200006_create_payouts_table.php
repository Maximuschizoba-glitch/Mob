<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{



    public function up(): void
    {
        Schema::create('payouts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('host_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('happening_id')->constrained('happenings')->cascadeOnDelete();
            $table->foreignId('escrow_id')->constrained('escrows')->cascadeOnDelete();
            $table->decimal('amount', 12, 2);
            $table->decimal('platform_fee', 12, 2);
            $table->string('status')->default('pending');
            $table->string('payout_reference')->nullable();
            $table->string('payout_gateway')->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->timestamps();
        });
    }




    public function down(): void
    {
        Schema::dropIfExists('payouts');
    }
};
