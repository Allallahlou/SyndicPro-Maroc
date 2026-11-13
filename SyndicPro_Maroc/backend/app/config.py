from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "SyndicPro Maroc API"
    database_url: str = "sqlite:///./syndicpro.db"
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
