#!/usr/bin/env python3
"""Verify locale completeness, fallback behavior and formatting."""
from pathlib import Path
import re

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"
LOCALE_DIR = ADDON / "Localization"
LOCALES = ("enUS", "zhCN", "zhTW")


def load_locale(locale):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().requested_locale = locale
    lua.execute("""
        SlashCmdList={}; FafnyirToolsDB={}; printed={}; ns={}
        function GetLocale() return requested_locale end
        function ns:GetDatabase() return FafnyirToolsDB end
        function ns:Print(message) printed[#printed+1]=message end
    """)
    lua.execute((LOCALE_DIR / "Core.lua").read_text(), "FafnyirTools", lua.globals().ns)
    for name in LOCALES:
        lua.execute((LOCALE_DIR / f"{name}.lua").read_text(), "FafnyirTools", lua.globals().ns)
    return lua


def keys_for(name):
    source = (LOCALE_DIR / f"{name}.lua").read_text()
    return set(re.findall(r'^\s*\["([^"]+)"\]\s*=', source, re.M))


def entries_for(name):
    source = (LOCALE_DIR / f"{name}.lua").read_text()
    return dict(re.findall(r'^\s*\["([^"]+)"\]\s*=\s*"((?:\\.|[^"\\])*)"', source, re.M))


def placeholders(value):
    return re.findall(r'%(?!%)(?:\d+\$)?[-+ #0]*\d*(?:\.\d+)?[cdeEfgGiouxXqs]', value)


english_keys = keys_for("enUS")
assert len(english_keys) == 187
for locale in LOCALES[1:]:
    translated_keys = keys_for(locale)
    assert len(translated_keys) == 187, locale
    assert translated_keys == english_keys, locale
    english = entries_for("enUS")
    translated = entries_for(locale)
    for key in translated_keys:
        assert placeholders(translated[key]) == placeholders(english[key]), (locale, key)

for locale in LOCALES:
    lua = load_locale(locale)
    ns = lua.globals().ns
    assert ns.Text(ns, "ABOUT.VERSION")
    assert ns.Text(ns, "BAGS_INVENTORY.BAGS_VALUE", 7).endswith("7")
    assert ns.Text(ns, "MISSING.TEST.KEY") == "MISSING.TEST.KEY"
    expected_forecast = {
        "enUS": "LEVELING FORECAST",
        "zhCN": "升级预测",
        "zhTW": "升級預測",
    }
    assert ns.Text(ns, "QOL.LEVELING_FORECAST") == expected_forecast[locale]

zh_cn = load_locale("zhCN")
assert zh_cn.globals().ns.Text(zh_cn.globals().ns, "CORE.ABOUT") != "About"
assert zh_cn.globals().ns.Text(zh_cn.globals().ns, "QOL.RETICLE_ONLY_WHILE_CLICKING") == "点击时显示准星"

zh_tw = load_locale("zhTW")
assert zh_tw.globals().ns.Text(zh_tw.globals().ns, "QOL.RETICLE_ONLY_WHILE_CLICKING") == "點擊時顯示準星"

unsupported = load_locale("frFR")
assert unsupported.globals().ns.Text(unsupported.globals().ns, "CORE.ABOUT") == "About"

for locale in LOCALES:
    source = (LOCALE_DIR / f"{locale}.lua").read_text()
    assert not re.search(r'=\s*""\s*,?$', source, re.M), locale

print("PASS enUS plus complete 187-key zhCN/zhTW coverage, English fallback, formatting, and missing-key behavior")
