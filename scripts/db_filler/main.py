import logging
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from agents.orchestrator import OrchestratorAgent

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

def main():
    logger = logging.getLogger(__name__)
    logger.info('Starting Database Filler')

    try:
        orchestrator = OrchestratorAgent()
        orchestrator.run()
        logger.info('Done!')
    except Exception as e:
        logger.error(f'Error: {e}')
        import traceback
        traceback.print_exc()
        raise

if __name__ == '__main__':
    main()