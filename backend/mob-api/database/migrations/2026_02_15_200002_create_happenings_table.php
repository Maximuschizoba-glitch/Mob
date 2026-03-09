<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{



    public function up(): void
    {
        Schema::create('happenings', function (Blueprint $table) {
            $table->id();
            $table->string('uuid')->unique();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->text('description');
            $table->string('category');
            $table->string('type');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->integer('radius_meters')->nullable();
            $table->string('address');
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->boolean('is_ticketed')->default(false);
            $table->decimal('ticket_price', 10, 2)->nullable();
            $table->integer('ticket_quantity')->nullable();
            $table->integer('tickets_sold')->default(0);
            $table->decimal('vibe_score', 5, 2)->default(0);
            $table->string('activity_level')->default('low');
            $table->string('status')->default('active');
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('latitude');
            $table->index('longitude');
            $table->index('expires_at');
            $table->index('status');
            $table->index('category');
        });
    }




    public function down(): void
    {
        Schema::dropIfExists('happenings');
    }
};
