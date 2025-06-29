package com.example.di

import com.example.repository.MbtiRepository
import com.example.repository.MbtiRepositoryImpl
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    @Singleton
    abstract fun bindMbtiRepository(
        impl: MbtiRepositoryImpl
    ): MbtiRepository
}
