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
assert len(english_keys) == 164
for locale in LOCALES[1:]:
    assert keys_for(locale) == english_keys, locale
    english = entries_for("enUS")
    translated = entries_for(locale)
    for key in english_keys:
        assert placeholders(translated[key]) == placeholders(english[key]), (locale, key)

for locale in LOCALES:
    lua = load_locale(locale)
    ns = lua.globals().ns
    assert ns.Text(ns, "ABOUT.VERSION")
    assert ns.Text(ns, "BAGS_INVENTORY.BAGS_VALUE", 7).endswith("7")
    assert ns.Text(ns, "MISSING.TEST.KEY") == "MISSING.TEST.KEY"

zh_cn = load_locale("zhCN")
assert zh_cn.globals().ns.Text(zh_cn.globals().ns, "CORE.ABOUT") != "About"

unsupported = load_locale("frFR")
assert unsupported.globals().ns.Text(unsupported.globals().ns, "CORE.ABOUT") == "About"

for locale in LOCALES:
    source = (LOCALE_DIR / f"{locale}.lua").read_text()
    assert not re.search(r'=\s*""\s*,?$', source, re.M), locale

print("PASS enUS/zhCN/zhTW locale parity, fallback, formatting, and missing-key behavior")
