"""Deterministic study-plan agents used by the /study-plan API.

These are not LLM-backed. They split the same work a coach would do:
profile the student, pick today's mix, explain how to study, and attach
honest incentives. Wired from app.py so the Flutter Practice tab can
load a personalized daily plan.
"""

from .orchestrator import generate_daily_plan, mark_daily_plan_complete

__all__ = ['generate_daily_plan', 'mark_daily_plan_complete']
